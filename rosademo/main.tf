# cat<<-EOF>main.tf
#
# Copyright (c) 2023 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.0"
    }
    rhcs = {
      version = ">= 1.6.2"
      source  = "terraform-redhat/rhcs"
    }
  }
}

# Export token using the RHCS_TOKEN environment variable

provider "rhcs" {
  token = "eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0NzQzYTkzMC03YmJiLTRkZGQtOTgzMS00ODcxNGRlZDc0YjUifQ.eyJpYXQiOjE3NjExNTY3MzgsImp0aSI6IjUzMzk0NmQ3LWE0YjYtNDY2My1iMGYzLTNkNTdkN2M5ZGJmYiIsImlzcyI6Imh0dHBzOi8vc3NvLnJlZGhhdC5jb20vYXV0aC9yZWFsbXMvcmVkaGF0LWV4dGVybmFsIiwiYXVkIjoiaHR0cHM6Ly9zc28ucmVkaGF0LmNvbS9hdXRoL3JlYWxtcy9yZWRoYXQtZXh0ZXJuYWwiLCJzdWIiOiJmOjUyOGQ3NmZmLWY3MDgtNDNlZC04Y2Q1LWZlMTZmNGZlMGNlNjp0d2ZlbndpY2tAZ21haWwuY29tIiwidHlwIjoiT2ZmbGluZSIsImF6cCI6ImNsb3VkLXNlcnZpY2VzIiwibm9uY2UiOiI3NThiNWIzNS0wYWIzLTRhM2UtOGE4NS03ZTIwMTVkMjJjMzAiLCJzaWQiOiIyZTMxZmU2Mi0zOGIxLTQ1NjctYjU1Ny1kNGUxYWIyNDc4M2MiLCJzY29wZSI6Im9wZW5pZCBiYXNpYyByb2xlcyB3ZWItb3JpZ2lucyBjbGllbnRfdHlwZS5wcmVfa2MyNSBvZmZsaW5lX2FjY2VzcyJ9.hIJr7KFj6nlJec5yJD_SwsFmyo1C5xUrf2tE3CA32QdmSBkq-ydJKjj4sllHQYzOSa_HyIsxFtMmqUzxUIQ8Lg"
}

provider "aws" {
  region = var.aws_region
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
  default_tags {
    tags = var.default_aws_tags
  }
}

data "aws_availability_zones" "available" {
  # state = "available"
  #
  # filter {
  #   name   = "region-name"
  #   values = [var.aws_region]
  # }
  #
  # # You can add more filters as needed, for example to filter by zone name
  # filter {
  #   name   = "zone-name"
  #   values = ["us-east-1a", "us-east-1c"]
  # }
}

locals {
  # The default setting creates 3 availability zones. Set to "false" to create a single availability zones.
  region_azs = var.multi_az ? slice([for zone in data.aws_availability_zones.available.names : format("%s", zone)], 0, 3) : slice([for zone in data.aws_availability_zones.available.names : format("%s", zone)], 0, 1)
}

resource "random_string" "random_name" {
  length  = 6
  special = false
  upper   = false
}

locals {
  path                 = coalesce(var.path, "/")
  worker_node_replicas = try(var.worker_node_replicas, var.multi_az ? 3 : 2)
  # If cluster_name is not null, use that, otherwise generate a random cluster name
  cluster_name = coalesce(var.cluster_name, "rosa-${random_string.random_name.result}")
}

# The network validator requires an additional 60 seconds to validate Terraform clusters.
resource "time_sleep" "wait_60_seconds" {
  count = var.create_vpc ? 1 : 0
  depends_on = [module.vpc]
  create_duration = "60s"
}

module "rosa-classic" {
  source                 = "terraform-redhat/rosa-classic/rhcs"
  version                = "1.7.0"
  cluster_name           = local.cluster_name
  openshift_version      = var.openshift_version
  account_role_prefix    = local.cluster_name
  operator_role_prefix   = local.cluster_name
  replicas               = local.worker_node_replicas
  aws_availability_zones = local.region_azs
  create_oidc            = true
  private                = var.private_cluster
  aws_private_link       = var.private_cluster
  aws_subnet_ids         = var.create_vpc ? var.private_cluster ? module.vpc[0].private_subnets : concat(module.vpc[0].public_subnets, module.vpc[0].private_subnets) : var.aws_subnet_ids
  multi_az               = var.multi_az
  create_account_roles   = true
  create_operator_roles  = true
# Optional: Configure a cluster administrator user \
#
#
# Option 1: Default cluster-admin user
# Create an administrator user (cluster-admin) and automatically
# generate a password by uncommenting the following parameter:
#  create_admin_user = true
# Generated administrator credentials are displayed in terminal output.

# Option 2: Specify administrator username and password
# Create an administrator user and define your own password
# by uncommenting and editing the values of the following parameters:
#  admin_credentials_username = <username>
#  admin_credentials_password = <password>

  depends_on = [time_sleep.wait_60_seconds]
}
provider "aws" {
  region     = "us-east-1"
}

# More likely to use environment variables for this. Or vault cli. like: vault kv get secret/hello
# Better for env var, b/c you could see it in cli history.
variable "username" {
  type = string
}
variable "password" {
  type = string
}

# Secret injection
data "vault_generic_secret" "dbuser" {
  path = "secret/dbuser"
}
data "vault_generic_secret" "dbpassword" {
  path = "secret/dbpassword"
}

provider "vault" {
  auth_login {
    path = auth/userpass/login/var.username
    parameters = {
      password = var.password
    }
  }
  address = ""
}

resource "aws_db_instance" "myrds" {
  name                = "mydb"
  identifier          = "my-first-rds"
  instance_class      = "db.t2.micro"
  engine              = "mysql"
  engine_version      = "5.7.22"
  username            = data.vault_generic_secret.dbuser.data["value"] # this confusing using "value", but because of how it's accessed. see below
  password            = data.vault_generic_secret.dbpassword.data["value"]
  port                = 3306
  allocated_storage   = 20
  skip_final_snapshot = true
}

# to get secret/dbuser. vault kv get secret/dbuser:
# {
#   value = "bob"
# }
# to get secret/dbpassword:
# {
#   value = "password"
# }
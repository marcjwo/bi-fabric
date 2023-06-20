variable "dataform_repository_name" {
  type = string
}

variable "dataform_remote_repository_token" {
  type = string
}

variable "dataform_remote_repository_url" {
  type = string
}

variable "dataform_remote_repository_branch" {
  type    = string
  default = "main"
}

variable "dataform_secret_name" {
  type = string
}

variable "region" {
  type = string
}

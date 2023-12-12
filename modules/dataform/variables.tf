variable "project_id" {
  type = string
}

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

variable "location" {
  type = string
}

variable "dataform_service_account" {
  type = string
}

variable "editors" {
  type = string
}

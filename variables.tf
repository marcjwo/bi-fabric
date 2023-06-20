variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west3"
}

variable "data_levels" {
  type = list(any)
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

variable "data_product_metadata_template_name" {
  type = string
}

variable "data_product_metadata_template_display_name" {
  type = string
}

# variable "fields" {
#   type = list(map(any))
# }

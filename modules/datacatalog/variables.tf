variable "data_product_metadata_template_name" {
  type = string
}

variable "data_product_metadata_template_display_name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "fields" {
  type = list(map(any))
}

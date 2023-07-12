variable "function_name" {
  type    = string
  default = "table_tagging"
}

variable "region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "service_account_name" {
  type = string
}

variable "cloud_function_src_dir" {
  type = string
}

variable "cloud_function_temp_dir" {
  type = string
}
variable "entry_point" {
  type = string
}

variable "resource_bucket_name" {
  type = string
}

# variable "bigquery_dataset_name" {
#   type = string
# }

variable "env_variables" {
  type = map(string)
}

variable "deployment_procedure_path" {
  type = string
}

variable "cloud_functions_sa_extra_roles" {
  type = list(string)
}

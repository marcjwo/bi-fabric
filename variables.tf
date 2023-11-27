variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "europe-west3"
}

# variable "region" {
#   type    = string
#   default = "europe-west3"
# }

# variable "terraform_sa" {
#   type = string
# }

variable "data_layers" {
  description = "Needs to be lowercase"
  type        = list(string)
}

variable "data_domains" {
  description = "Needs to be lowercase"
  type        = list(string)
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

variable "composer_config" {
  description = "Composer environment configuration. It accepts only following attributes: `environment_size`, `software_config` and `workloads_config`. See [attribute reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/composer_environment#argument-reference---cloud-composer-2) for details on settings variables."
  type = object({
    environment_size = string
    software_config  = any
    workloads_config = object({
      scheduler = object(
        {
          cpu        = number
          memory_gb  = number
          storage_gb = number
          count      = number
        }
      )
      web_server = object(
        {
          cpu        = number
          memory_gb  = number
          storage_gb = number
        }
      )
      worker = object(
        {
          cpu        = number
          memory_gb  = number
          storage_gb = number
          min_count  = number
          max_count  = number
        }
      )
    })
  })
  default = {
    environment_size = "ENVIRONMENT_SIZE_SMALL"
    software_config = {
      image_version = "composer-2-airflow-2"
    }
    workloads_config = null
  }
}

# variable "data_product_metadata_template_name" {
#   type = string
# }

# variable "data_product_metadata_template_display_name" {
#   type = string
# }

# variable "tag_templates" {
#   type = list(object({
#     id           = string
#     display_name = optional(string)
#     force_delete = optional(bool)
#     fields = list(object({
#       id           = string
#       type         = string
#       values       = optional(list(string))
#       description  = optional(string)
#       display_name = optional(string)
#       is_required  = optional(bool)
#       order        = optional(number)
#     }))
#   }))
#   validation {
#     condition     = can([for tag_template in var.tag_templates : regex("^[a-z_][a-z0-9_]{0,63}$", tag_template["id"])])
#     error_message = "Each of the 'tag_templates' id values must start with a letter (a-z) or underscore (_) and only contain letters (a-z), numbers(0-9) or underscores(_). It can be at most 64 bytes long when encoded in UTF-8."
#   }

#   validation {
#     condition     = can([for tag_template in var.tag_templates : regex("^[^\\s][a-zA-Z0-9_\\s]{0,199}[^\\s]$", tag_template["display_name"])])
#     error_message = "Each of the 'tag_templates' display names must NOT start or end with a space. It must contain only unicode letters, numbers, underscores, dashes and spaces. It can be at most 200 bytes long when encoded in UTF-8."
#   }

#   validation {
#     condition     = alltrue([for tag_template in var.tag_templates : alltrue([for field in tag_template["fields"] : contains(["BOOL", "DOUBLE", "ENUM", "STRING", "TIMESTAMP"], field["type"])])])
#     error_message = "Supported types are 'BOOL', 'DOUBLE', 'ENUM', 'STRING' and 'TIMESTAMP'."
#   }

#   validation {
#     condition     = alltrue([for tag_template in var.tag_templates : alltrue([for field in tag_template["fields"] : length(regexall("^[a-zA-Z_][a-zA-Z0-9_]{0,63}$", field["id"])) > 0])])
#     error_message = "Field IDs must start with a letter or underscore. Field IDs must be unique within their template. Field IDs must be at least 1 character long and at most 64 bytes long when encoded in UTF-8."
#   }
# }

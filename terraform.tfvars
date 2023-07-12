project_id                        = "blaa-bi-in-a-box"
data_levels                       = ["source", "intermediate", "output"]
data_domains                      = ["orders", "users"]
dataform_repository_name          = "thelook_ecommerce"
dataform_remote_repository_url    = "https://github.com/marcjwo/thelook_dataform"
dataform_remote_repository_token  = "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"
dataform_secret_name              = "dataform_secret"
dataform_remote_repository_branch = "main"
region                            = "europe-west3"
# data_product_metadata_template_name         = "metadata_template"
# data_product_metadata_template_display_name = "metadata_template_display_name"
tag_templates = [{
  id           = "tag_template1"
  display_name = "tag_template1"
  force_delete = true
  fields = [{
    order       = 1
    id          = "data_owner"
    type        = "STRING"
    is_required = true
    }, {
    id           = "data_level"
    display_name = "Data Level"
    order        = 3
    type         = "ENUM"
    values = [
      "source",
      "intermediate",
      "output"
    ]
    is_required = true
    },
    {
      order       = 2
      id          = "data_domain"
      type        = "STRING"
      is_required = true
    }
  ]
}]

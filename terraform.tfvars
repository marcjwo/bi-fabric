project_id                        = "semantics-390012"
data_levels                       = ["source_aligned", "transformed", "analytical"]
data_domains                      = ["marketing", "sales", "hr"]
dataform_repository_name          = "dataform_repository"
dataform_remote_repository_url    = "https://github.com"
dataform_remote_repository_token  = "bkjklmklmkl"
dataform_secret_name              = "dataform_secret"
dataform_remote_repository_branch = "main"
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
      "source_aligned",
      "transformed",
      "analytical"
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

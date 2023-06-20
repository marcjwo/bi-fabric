resource "google_data_catalog_tag_template" "tag_template_data_product_metadata" {

  tag_template_id = var.data_product_metadata_template_name
  display_name    = var.data_product_metadata_template_display_name
  project         = var.project_id
  region          = var.region

  fields {
    field_id     = "num_rows"
    display_name = "Number of rows in the data asset"
    type {
      primitive_type = "DOUBLE"
    }
  }

  force_delete = true
}

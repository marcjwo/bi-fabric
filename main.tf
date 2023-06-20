/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


module "bigquery" {
  count = length(var.data_levels)

  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/bigquery-dataset"
  project_id = var.project_id
  location   = var.region
  id         = var.data_levels[count.index]
  labels     = { "data_level" : var.data_levels[count.index] }
}

module "dataform" {
  source                           = "./modules/dataform"
  region                           = var.region
  dataform_secret_name             = var.dataform_secret_name
  dataform_repository_name         = var.dataform_repository_name
  dataform_remote_repository_url   = var.dataform_remote_repository_url
  dataform_remote_repository_token = var.dataform_remote_repository_url
}

# module "datacatalog" {
#   source                                      = "./modules/datacatalog"
#   project_id                                  = var.project_id
#   region                                      = var.region
#   data_product_metadata_template_name         = var.data_product_metadata_template_name
#   data_product_metadata_template_display_name = var.data_product_metadata_template_display_name
# }

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

# locals {
#   domains_and_levels = { for combination in setproduct(var.data_domains, var.data_levels) : "${combination[0]}-${combination[1]}" => combination }
# }

# data "google_project" "project" {
#   project_id = var.project_id
# }

# locals {
#   service_account_dataform = "service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
#   config                   = yamldecode(file("config.yaml"))
# }



# module "bigquery" {
#   source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/bigquery-dataset"
#   project_id = var.project_id
#   location   = var.location
#   for_each = {
#     for c in setproduct(var.data_domains, var.data_layers) : "${c[0]}_${c[1]}" => {
#       domain = c[0]
#       layer  = c[1]
#     }
#   }
#   id     = "${each.value.domain}_${each.value.layer}"
#   labels = { "data_domain" : "${each.value.domain}", "data_layer" : "${each.value.layer}", "provisioned_by" : "terraform" }
#   options = {
#     delete_contents_on_destroy = true
#     is_case_insensitive        = true
#   }
# }

# module "dataform" {
#   source                           = "./modules/dataform"
#   project_id                       = var.project_id
#   location                         = var.location
#   dataform_secret_name             = var.dataform_secret_name
#   dataform_repository_name         = var.dataform_repository_name
#   dataform_remote_repository_url   = var.dataform_remote_repository_url
#   dataform_remote_repository_token = var.dataform_remote_repository_token
#   service_account_dataform         = local.service_account_dataform
# }

# module "dataplex" {
#   source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/dataplex"
#   project_id = var.project_id
#   region     = var.location
#   for_each = {
#     for c in setproduct(var.data_domains, var.data_layers) : "${c[0]}_${c[1]}" => {
#       domain = c[0]
#       layer  = c[1]
#     }
#   }
#   name = each.value.domain
#   zones = {
#     "${each.value.layer}" = {
#       type      = "${each.value.layer}"
#       discovery = true
#       assets = {
#         bq_1 = {
#           resource_name          = "${each.value.domain}_${each.value.layer}"
#           discovery_spec_enabled = true
#           resource_spec_type     = "BIGQUERY_DATASET"
#         }
#       }
#     }
#   }
# }

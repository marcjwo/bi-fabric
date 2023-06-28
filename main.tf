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

data "google_project" "project" {
  project_id = var.project_id
}

locals {
  service_account_dataform = "service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
  levels                   = concat(var.data_levels, ["resources"])
  apis_to_activate = [
    "artifactregistry",
    "bigquery",
    "bigqueryconnection",
    "cloudbuild",
    "cloudfunctions",
    "run",
    "eventarc",
    "logging",
    "pubsub",
  ]
}

resource "google_project_service" "apis_to_activate" {
  count                      = length(local.apis_to_activate)
  project                    = var.project_id
  service                    = "${local.apis_to_activate[count.index]}.googleapis.com"
  disable_dependent_services = true

}

resource "google_storage_bucket" "resources_bucket" {
  name                        = "${var.project_id}-resources"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

### build datasets for the different data levels + resource level
module "bigquery" {
  count      = length(local.levels)
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/bigquery-dataset"
  project_id = var.project_id
  location   = var.region
  id         = local.levels[count.index]
  labels     = { "level" : local.levels[count.index] }
}

module "dataform" {
  source                           = "./modules/dataform"
  project_id                       = var.project_id
  region                           = var.region
  dataform_secret_name             = var.dataform_secret_name
  dataform_repository_name         = var.dataform_repository_name
  dataform_remote_repository_url   = var.dataform_remote_repository_url
  dataform_remote_repository_token = var.dataform_remote_repository_url
  service_account_dataform         = local.service_account_dataform
}

module "datacatalog" {
  source        = "./modules/datacatalog"
  project_id    = var.project_id
  region        = var.region
  tag_templates = var.tag_templates
}

module "tagging" {
  source                  = "./modules/tagging"
  project_id              = var.project_id
  region                  = var.region
  cloud_function_src_dir  = "./functions/tagging"
  cloud_function_temp_dir = "/tmp/tagging.zip"
  service_account_name    = "tagging-cloud-function"
  entry_point             = "process_request"
  env_variables = {
    TAG_TEMPLATE_PROJECT : var.project_id
    TAG_TEMPLATE_REGION : var.region
    TAG_TEMPLATE_ID : var.tag_templates[0]["id"]
  }
  resource_bucket_name      = google_storage_bucket.resources_bucket.name
  bigquery_dataset_name     = module.bigquery[length(local.levels) - 1].dataset_id
  deployment_procedure_path = "modules/tagging/procedures/deploy_tagging.tpl"
  cloud_functions_sa_extra_roles = [
    "roles/datacatalog.tagEditor",
    "roles/datacatalog.tagTemplateUser",
    "roles/datacatalog.viewer"
  ]
}

## Todo: Consumption Infrastructure -- Vertex Workbench, Looker

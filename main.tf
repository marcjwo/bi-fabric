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
  # depends_on = [time_sleep.wait_api_activation]
}

locals {
  service_account_dataform = "service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
  # levels                   = concat(lower(var.data_levels), ["resources"])
  # levels             = var.data_levels
  domains_and_levels = {
    for combination in setproduct(var.data_domains, var.data_levels) : combination[0] => combination[1]...
  }

  apis_to_activate = [
    "serviceusage",
    "cloudresourcemanager",
    "secretmanager",
    "datacatalog",
    "artifactregistry",
    "bigquery",
    "bigqueryconnection",
    "cloudbuild",
    "cloudfunctions",
    "run",
    "eventarc",
    "logging",
    "pubsub",
    "dataplex",
    "iam",
    "dataform",
    "analyticshub"
    # "console"
  ]
  bi_service_account_roles = [
    "roles/bigquery.jobUser",
    "roles/bigquery.dataViewer",
    "roles/bigquery.dataEditor"
  ]
  ### dataEditor only required if data needs to be edited, i.e. via Looker persistent derived tables
}

resource "google_project_service" "apis_to_activate" {
  for_each           = toset(local.apis_to_activate)
  project            = var.project_id
  service            = "${each.key}.googleapis.com"
  disable_on_destroy = false
  # disable_dependent_services = true
  timeouts {
    create = "10m"
    update = "40m"
  }
}

resource "time_sleep" "wait_api_activation" {
  create_duration = "120s"
  depends_on      = [google_project_service.apis_to_activate]
}


module "bi_service_account" {
  source = "./modules/service_account"
  # count                        = length(local.bi_service_account_roles)
  # for_each                     = local.bi_service_account_roles
  project_id                   = var.project_id
  service_account_name         = "bi-service-account"
  service_account_display_name = "SA to be used for BI connection (Looker)"
  # service_account_roles        = local.bi_service_account_roles[count.index]
  service_account_roles = local.bi_service_account_roles
  depends_on            = [time_sleep.wait_api_activation]
}


resource "google_storage_bucket" "resources_bucket" {
  name                        = "${var.project_id}-resources"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  depends_on                  = [time_sleep.wait_api_activation]
}

### build datasets for the different data levels + resource level!!!!!!!!!!1 resource level needs to be separate
# module "bigquery" {
#   # count      = length(local.levels)
#   count      = length(local.domains_and_levels)
#   source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/bigquery-dataset"
#   project_id = var.project_id
#   location   = var.region
#   id         = "${local.domains_and_levels[count.index][0]}-${local.domains_and_levels[count.index][1]}"
#   labels     = { "domain" : local.domains_and_levels[count.index][0], "level" : local.domains_and_levels[count.index][1] }
# }

module "bigquery" {
  source     = "./modules/bigquery"
  project_id = var.project_id
  region     = var.region
  domains    = var.data_domains
  levels     = var.data_levels
  depends_on = [time_sleep.wait_api_activation]
}

# module "bigquery" {
#   source             = "./modules/bigquery"
#   project_id         = var.project_id
#   region             = var.region
#   count              = length(local.domains_and_levels)
#   id                 = "${local.domains_and_levels[count.index][0]}_${local.domains_and_levels[count.index][1]}"
#   labels             = { "domain" : local.domains_and_levels[count.index][0], "level" : local.domains_and_levels[count.index][1], "provisioned_by" : "terraform" }
#   lake_name          = local.domains_and_levels[count.index][0]
#   lake_display_name  = "Data Lake for ${local.domains_and_levels[count.index][0]} domain"
#   lake_label         = { "domain" : local.domains_and_levels[count.index][0] }
#   zone_name          = "${local.domains_and_levels[count.index][0]}-${local.domains_and_levels[count.index][1]}"
#   zone_display_name  = "Zone for ${local.domains_and_levels[count.index][1]} data"
#   zone_label         = { "level" : local.domains_and_levels[count.index][1] }
#   asset_name         = "${local.domains_and_levels[count.index][0]}-${local.domains_and_levels[count.index][1]}_dataset"
#   asset_display_name = "${local.domains_and_levels[count.index][0]}-${local.domains_and_levels[count.index][1]} Dataset Asset"
#   asset_label        = { "domain" : local.domains_and_levels[count.index][0], "level" : local.domains_and_levels[count.index][1] }
#   depends_on         = [google_project_service.apis_to_activate]
# }

module "dataform" {
  source                           = "./modules/dataform"
  project_id                       = var.project_id
  region                           = var.region
  dataform_secret_name             = var.dataform_secret_name
  dataform_repository_name         = var.dataform_repository_name
  dataform_remote_repository_url   = var.dataform_remote_repository_url
  dataform_remote_repository_token = var.dataform_remote_repository_token
  service_account_dataform         = local.service_account_dataform
  depends_on                       = [time_sleep.wait_api_activation]
}

module "datacatalog" {
  source        = "./modules/datacatalog"
  project_id    = var.project_id
  region        = var.region
  tag_templates = var.tag_templates
  depends_on    = [time_sleep.wait_api_activation]
}

module "tagging" {
  source                  = "./modules/cloudfunction"
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
  resource_bucket_name = google_storage_bucket.resources_bucket.name
  # bigquery_dataset_name     = module.bigquery[length(local.levels) - 1].dataset_id
  # bigquery_dataset_name     = module.bigquery.resources_dataset
  deployment_procedure_path = "modules/cloudfunction/procedures/deploy_tagging.tpl"
  cloud_functions_sa_extra_roles = [
    "roles/datacatalog.tagEditor",
    "roles/datacatalog.tagTemplateUser",
    "roles/datacatalog.viewer"
  ]
  depends_on = [time_sleep.wait_api_activation]
}

## Todo: Consumption Infrastructure -- Vertex Workbench, Looker

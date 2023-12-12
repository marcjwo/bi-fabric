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

locals {
  config             = yamldecode(file("config.yaml"))
  control_project_id = "${local.config.general_settings.project-prefix}-${local.config.control.project_id}"
  control_apis = [
    "bigquery.googleapis.com",
    "dataform.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
  ]
  groups = {
    for k, v in local.config.iam : k => "${v}@${local.config.general_settings.organization-domain}"
  }
  groups_iam = {
    for k, v in local.groups : k => "group:${v}"
  }
}

module "control_project" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/project"
  name            = local.control_project_id
  billing_account = local.config.general_settings.control_billing_account
  parent          = local.config.general_settings.control_parent_folder
  services        = local.control_apis
}

module "pipeline_sa" { # service account to be used for the data pipeline in dataform
  source      = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/iam-service-account"
  name        = local.config.control.pipeline_sa
  project_id  = local.config.control.project_id
  description = "Service account for the data pipeline in dataform"
}

module "dataform" {
  source                           = "./modules/dataform"
  project_id                       = local.control_project_id
  location                         = local.config.control.location
  dataform_secret_name             = local.config.dataform.dataform_secret_name
  dataform_repository_name         = local.config.dataform.dataform_repository_name
  dataform_remote_repository_url   = local.config.dataform.dataform_remote_repository_url
  dataform_remote_repository_token = local.config.dataform.dataform_remote_repository_token
  dataform_service_account         = module.pipeline_sa.iam_email
  editors                          = local.groups_iam.data_engineers
  depends_on                       = [module.control_project]
}

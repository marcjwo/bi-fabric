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
  config = yamldecode(file("config.yaml"))
}

module "tooling_project" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/project"
  name            = local.config.tooling.project_id
  billing_account = local.config.general_settings.tooling_billing_account
  parent          = local.config.general_settings.tooling_parent_folder
}

# resource "google_composer_environment" "tooling" {
#   name       = "${local.config.tooling.project_id}-composer"
#   project    = local.config.tooling.project_id
#   region     = local.config.tooling.location
#   depends_on = [module.tooling_project]
# }

# module "dataform" {
#   source                   = "./modules/dataform"
#   dataform_repository_name = "dataform-tooling-repository"
#   dataform_service_account = "das@das.de"
#   project_id = local.config.tooling.project_id
#   location = local.config.tooling.location
#   dataform_remote_repository_url = "https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git"
#   dataform_remote_repository_branch = "main"
#   dataform_secret_name = test
# }

# resource "google_dataform_repository" "tooling" {
#   provider = google-beta
#   region   = local.config.tooling.location
#   name     = "${local.config.tooling.project_id}-dataform-repository"
# }

# resource "google_dataform_repository_release_config" "tooling" {
#   provider      = google-beta
#   project       = local.config.tooling.project_id
#   region        = local.config.tooling.location
#   repository    = google_dataform_repository.tooling.name
#   name          = "tooling-release-config"
#   git_commitish = "main"

# }

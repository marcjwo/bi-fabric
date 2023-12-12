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
  core_apis = [
    "bigquery.googleapis.com",
  ]
  core_layer      = element([for layer in local.config.layers : layer if layer.name == "core"], 0)
  core_project_id = "${local.config.general_settings.project-prefix}-${local.core_layer.name}"
  core_iam = {
    "roles/bigquery.dataEditor" = [
      module.pipeline_sa.iam_email,
      local.groups_iam.data_engineers
    ]
    "roles/bigquery.dataViewer" = [
      module.pipeline_sa.iam_email
    ]
    "roles/bigquery.jobUser" = [
      module.pipeline_sa.iam_email
    ]
    "roles/bigquery.dataOwner" = [
      module.pipeline_sa.iam_email
    ]
    "roles/storage.objectCreator" = [
      local.groups_iam.data_engineers
    ]
  }
  core_iam_additive = {
    for k in flatten([
      for role, members in local.core_iam : [
        for member in members : {
          role   = role
          member = member
        }
      ]
    ]) : "${k.member}-${k.role}" => k
  }
}

module "core_layer_project" {
  source                = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/project"
  name                  = local.core_project_id
  project_create        = local.core_layer != null
  billing_account       = local.config.general_settings.layers_billing_account
  parent                = local.config.general_settings.layers_parent_folder
  depends_on            = [module.control_project]
  iam                   = local.core_iam
  iam_bindings_additive = local.core_iam_additive
}

module "core_layer_datasets" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/bigquery-dataset"
  project_id = module.core_layer_project.project_id
  location   = local.config.control.location
  for_each   = toset(local.core_layer.envs)
  id         = "${local.core_layer.name}-${each.key}"
  depends_on = [module.core_layer_project]
}

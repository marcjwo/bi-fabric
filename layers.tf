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
  layers = {
    for l in local.config.layers : l.name => l
  }
}

module "data_layer_projects" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/project"
  for_each        = local.layers
  name            = each.value.name
  billing_account = local.config.general_settings.layers_billing_account
  parent          = local.config.general_settings.layers_parent_folder
  depends_on      = [module.tooling_project]
}

module "bigquery" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/bigquery-dataset"
  for_each = {
    for idx, layer in flatten([
      for idx, layer in local.config["layers"] : [
        for env in layer["envs"] : {
          idx        = idx
          dataset_id = env
          project    = layer["name"]
          location   = layer["location"]
          #   friendly_name = "${layer["name"]}-${env}"
        }
      ]
    ]) : idx => layer
  }

  id         = each.value["dataset_id"]
  project_id = each.value["project"]
  location   = each.value["location"]
  labels = {
    "data_layer" : each.value["project"],
    "data_environment" : each.value["dataset_id"],
    "provisioned_by" : "terraform"
  }
  depends_on = [module.data_layer_projects]

  #   for_each = { for c in setproduct(toset(local.config.layers.name), toset(local.config.layers.envs)) : "${c[0]}_${c[1]}" => {
  #     name     = c[0]
  #     location = c[1]
  #     env      = c[2]
  #   } }
  #   project_id = each.value.name
  #   location   = each.value.location
  #   id         = each.value.env
  #   # for_each = {
  #   #   for c in setproduct(var.data_domains, var.data_layers) : "${c[0]}_${c[1]}" => {
  #   #     domain = c[0]
  #   #     layer  = c[1]
  #   #   }
  #   # }
  #   # id     = "${each.value.domain}_${each.value.layer}"
  #   # labels = { "data_domain" : "${each.value.domain}", "data_layer" : "${each.value.layer}", "provisioned_by" : "terraform" }
  #   # options = {
  #   #   delete_contents_on_destroy = true
  #   #   is_case_insensitive        = true
  #   # }
}

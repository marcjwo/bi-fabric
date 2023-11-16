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

module "bigquery" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/bigquery-dataset"
  project_id = var.project_id
  location   = var.location
  for_each = {
    for c in setproduct(var.data_domains, var.data_levels) : "${c[0]}_${c[1]}" => {
      domain = c[0]
      level  = c[1]
    }
  }
  id     = "${each.value.domain}_${each.value.level}"
  labels = { "data_domain" : "${each.value.domain}", "data_level" : "${each.value.level}", "provisioned_by" : "terraform" }
  options = {
    delete_contents_on_destroy = true
    is_case_insensitive        = true
  }
}

module "dataplex" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric/modules/dataplex"
  project_id = var.project_id
  region     = var.location
  for_each = {
    for c in setproduct(var.data_domains, var.data_levels) : "${c[0]}_${c[1]}" => {
      domain = c[0]
      level  = c[1]
    }
  }
  name = each.value.domain
  zones = {
    "${each.value.level}" = {
      type      = "${each.value.level}"
      discovery = true
      assets = {
        bq_1 = {
          resource_name          = "${each.value.domain}_${each.value.level}"
          discovery_spec_enabled = true
          resource_spec_type     = "BIGQUERY_DATASET"
        }
      }
    }
  }
}



# resource "aws_sqs_queue" "queue" {
#   for_each = {
#     for q in local.queues : "${q[0]}-${q[1]}" => {
#       module = q[0]
#       stage  = q[1]
#     }
#   }

#   name = "${each.value.module}-${each.value.stage}"

#   tags = {
#     Module = each.value.module
#     Stage  = each.value.stage
#   }
# }

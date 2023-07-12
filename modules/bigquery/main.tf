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
#   domains = var.domains
#   levels  = var.levels
#   # levels  = ["raw", "done", "pimmel"]
#   # domains = ["marketing", "hr"]
#   # levels  = ["raw", "done", "pimmel"]
#   # combinations = setproduct(local.domains, local.levels)
#   # subnet_ranges = {
#   #   for pair in setproduct(local.domains, local.levels) : pair[0] => pair[1]...
#   # }


#   step_inbetween = [
#     for index, domain in local.domains : {
#       domain = domain
#       levels = local.levels
#     }
#   ]

#   transformed = { for domain in local.step_inbetween : domain["domain"] => domain }

#   datasets = flatten([
#     for domain in local.step_inbetween : [
#       for dataset in domain["levels"] : {
#         domain = domain["domain"]
#         level  = dataset

#       }
#     ]
#   ])
#   test = { for entry in local.datasets : "${entry.domain}_${entry.level}" => entry }
# }

# resource "random_string" "random" {
#   length = 4
#   lower  = true
#   upper  = false
# }

# resource "google_bigquery_dataset" "dataset" {
#   for_each   = { for entry in local.datasets : "${entry.domain}_${entry.level}" => entry }
#   project    = var.project_id
#   location   = var.region
#   dataset_id = each.key
#   labels     = { "domain" : each.value["domain"], "level" : each.value["level"], "provisioned_by" : "terraform" }
#   # labels     = var.labels
#   delete_contents_on_destroy = true
# }

resource "google_bigquery_dataset" "dataset_new" {
  project                    = var.project_id
  location                   = var.region
  for_each                   = toset(var.levels)
  dataset_id                 = "${var.domain}_${each.value}"
  labels                     = { "domain" : "${var.domain}", "level" : each.value, "provisioned_by" : "terraform" }
  delete_contents_on_destroy = true
  lifecycle {
    ignore_changes = [labels]
  }
}

# resource "google_bigquery_analytics_hub_data_exchange" "exchange" {
#   location         = var.region
#   for_each         = local.transformed
#   data_exchange_id = each.key
#   display_name     = "Data Exchange for ${each.key} domain"
# }

resource "google_data_catalog_entry_group" "this" {
  entry_group_id = var.domain
  display_name   = "${var.domain} entry group"
  region         = var.region
  project        = var.project_id
}

resource "google_data_catalog_entry" "this" {
  entry_group     = google_data_catalog_entry_group.this.id
  for_each        = toset(var.levels)
  entry_id        = each.value
  linked_resource = "//bigquery.googleapis.com/projects/${var.project_id}/datasets"
}

resource "google_bigquery_analytics_hub_data_exchange" "exchange_new" {
  # for_each         = local.transformed
  location         = var.region
  data_exchange_id = var.domain
  display_name     = "Data Exchange for ${var.domain} domain"
  depends_on       = [google_bigquery_dataset.dataset_new]
}

# resource "google_bigquery_analytics_hub_listing" "listing" {
#   for_each         = { for entry in local.datasets : "${entry.domain}_${entry.level}" => entry }
#   location         = var.region
#   data_exchange_id = each.value["domain"]
#   listing_id       = each.value["level"]
#   display_name     = "Listing for ${each.value["level"]} layer of ${each.value["domain"]}"
#   bigquery_dataset {
#     dataset = "projects/${var.project_id}/datasets/${each.value["domain"]}_${each.value["level"]}"
#   }
# }

resource "google_bigquery_analytics_hub_listing" "listing_new" {
  # for_each         = { for entry in local.datasets : "${entry.domain}_${entry.level}" => entry }
  location         = var.region
  data_exchange_id = var.domain
  for_each         = toset(var.levels)
  listing_id       = each.value
  display_name     = "Listing for ${each.value} layer of ${var.domain} zone"
  bigquery_dataset {
    dataset = "projects/${var.project_id}/datasets/${var.domain}_${each.value}"
  }
  depends_on = [google_bigquery_analytics_hub_data_exchange.exchange_new]
}

# resource "google_dataproc_metastore_service" "service" {
#   project    = var.project_id
#   location   = var.region
#   tier       = "DEVELOPER"
#   service_id = "metastore-service-for-${var.domain}"
#   labels     = { "domain" : "${var.domain}", "provisioned_by" : "terraform" }
#   timeouts {

#   }
# }

# resource "google_dataplex_lake" "lake" {
#   for_each     = local.transformed
#   location     = var.region
#   project      = var.project_id
#   name         = each.key
#   display_name = "Data Lake for ${each.key} domain"
#   labels       = { "domain" : each.key }
#   # metastore {
#   #   service = "projects/${var.project_id}/locations/${var.region}/services/dataproc-service-for-${each.key}"
#   # }
#   # depends_on = [google_dataproc_metastore_service.service]
#   # display_name = var.lake_display_name
#   # labels       = var.lake_label
# }

# resource "google_dataplex_lake" "lake_new" {
#   location     = var.region
#   project      = var.project_id
#   name         = var.domain
#   display_name = "Data Lake for ${var.domain} domain"
#   labels       = { "domain" : "${var.domain}" }
#   metastore {
#     service = "projects/${var.project_id}/locations/${var.region}/services/dataproc-service-for-${var.domain}"
#   }
#   depends_on = [google_dataproc_metastore_service.service]
#   # display_name = var.lake_display_name
#   # labels       = var.lake_label
# }

# resource "google_dataplex_zone" "zone" {
#   for_each = { for entry in local.datasets : "${entry.domain}_${entry.level}" => entry }
#   location = var.region
#   project  = var.project_id
#   type     = "CURATED"
#   discovery_spec {
#     enabled = true
#   }
#   resource_spec {
#     location_type = "SINGLE_REGION"
#   }
#   lake = each.value["domain"]
#   # name = random_string.random
#   name         = "${each.value["domain"]}-${replace(each.value["level"], "_", "-")}-zone"
#   display_name = "Zone for ${each.value["level"]} level"
#   labels       = { "level" : each.value["level"], "domain" : each.value["domain"], "provisioned_by" : "terraform", "generated_by" : "dataplex" }
#   depends_on   = [google_dataplex_lake.lake]
# }

# resource "google_dataplex_zone" "zone_new" {
#   # for_each = { for entry in local.datasets : "${entry.domain}_${entry.level}" => entry }
#   for_each = toset(var.levels)
#   location = var.region
#   project  = var.project_id
#   type     = "CURATED"
#   discovery_spec {
#     enabled = true
#   }
#   resource_spec {
#     location_type = "SINGLE_REGION"
#   }
#   lake = var.domain
#   # name = random_string.random
#   name         = "${var.domain}-${replace(each.value, "_", "-")}-zone"
#   display_name = "Zone for ${each.value} level"
#   labels       = { "level" : each.value, "domain" : "${var.domain}", "provisioned_by" : "terraform", "generated_by" : "dataplex" }
#   depends_on   = [google_dataplex_lake.lake_new]
# }

# resource "google_dataplex_asset" "asset" {
#   for_each = { for entry in local.datasets : "${entry.domain}_${entry.level}" => entry }
#   location = var.region
#   project  = var.project_id
#   discovery_spec {
#     enabled = true
#   }
#   dataplex_zone = "${each.value["domain"]}-${replace(each.value["level"], "_", "-")}-zone"
#   lake          = each.value["domain"]
#   resource_spec {
#     type = "BIGQUERY_DATASET"
#     name = "projects/${var.project_id}/datasets/${each.value["domain"]}_${each.value["level"]}"

#   }
#   name         = replace(each.key, "_", "-")
#   display_name = "Asset for ${each.key}"
#   # labels       = var.asset_label
#   depends_on = [google_dataplex_zone.zone]
# }

# resource "google_dataplex_asset" "asset_new" {
#   # for_each = { for entry in local.datasets : "${entry.domain}_${entry.level}" => entry }
#   location = var.region
#   project  = var.project_id
#   for_each = toset(var.levels)
#   discovery_spec {
#     enabled = true
#   }
#   dataplex_zone = "${var.domain}-${replace(each.value, "_", "-")}-zone"
#   lake          = var.domain
#   resource_spec {
#     type = "BIGQUERY_DATASET"
#     name = "projects/${var.project_id}/datasets/${var.domain}_${each.value}"

#   }
#   name         = replace(each.key, "_", "-")
#   display_name = "Asset for ${var.domain} - ${each.key}"
#   # labels       = var.asset_label
#   depends_on = [google_dataplex_zone.zone_new]
# }

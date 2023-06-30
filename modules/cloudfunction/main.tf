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


# Cloud Source Repositories unfortunately not yet supported by dataform!
# resource "google_sourcerepo_repository" "git_repository" {
#   provider = google-beta
#   name     = "my/repository"
# }

locals {
  cf_service_account_roles = concat([
    "roles/logging.logWriter",
    "roles/artifactregistry.reader"
  ], var.cloud_functions_sa_extra_roles)
}

module "cf_service_account" {
  source = "../service_account"
  # count                        = length(local.cf_service_account_roles)
  # for_each                     = local.cf_service_account_roles
  project_id                   = var.project_id
  service_account_name         = "cf-service-account"
  service_account_display_name = "SA to be used for Cloud Function ${var.function_name}"
  service_account_roles        = local.cf_service_account_roles
  # service_account_roles        = local.cf_service_account_roles[count.index]
}

# resource "google_service_account" "sa_function" {
#   project      = var.project_id
#   account_id   = var.service_account_name
#   display_name = "Runtime SA for Cloud Function ${var.function_name}"
# }

# resource "google_project_iam_member" "sa_function_roles" {
#   project = var.project_id
#   for_each = toset(concat([
#     "roles/logging.logWriter",
#     "roles/artifactregistry.reader"
#     ],
#     var.cloud_functions_sa_extra_roles
#   ))
#   role   = each.key
#   member = "serviceAccount:${google_service_account.sa_function.email}"
# }

resource "google_bigquery_connection" "tagging" {
  connection_id = var.function_name
  location      = var.region
  project       = var.project_id
  description   = "Connection required for the tagging remote function"
  cloud_resource {

  }
}

resource "google_cloud_run_service_iam_member" "bigquery_connection_service_account" {
  project    = var.project_id
  location   = var.region
  service    = google_cloudfunctions2_function.function.service_config[0].service
  role       = "roles/run.invoker"
  member     = "serviceAccount:${google_bigquery_connection.tagging.cloud_resource[0].service_account_id}"
  depends_on = [google_bigquery_connection.tagging]
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = var.cloud_function_src_dir
  output_path = var.cloud_function_temp_dir
}

resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files' content
  # to force the zip to be updated as soon as a change occurs
  name       = "src-${data.archive_file.source.output_md5}.zip"
  bucket     = var.resource_bucket_name
  depends_on = [data.archive_file.source]
}

resource "google_cloudfunctions2_function" "function" {
  name     = var.function_name
  project  = var.project_id
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = var.resource_bucket_name
        object = google_storage_bucket_object.zip.name
      }
    }
  }

  service_config {
    max_instance_count               = 3
    min_instance_count               = 1
    available_memory                 = "1Gi"
    timeout_seconds                  = 60
    max_instance_request_concurrency = 80
    available_cpu                    = "2"
    environment_variables            = var.env_variables
    ingress_settings                 = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision   = true
    service_account_email            = module.cf_service_account.email
    # service_account_email = module.cf_service_account.email
  }
  depends_on = [google_storage_bucket_object.zip]
}

resource "google_bigquery_dataset" "resources" {
  project                    = var.project_id
  location                   = var.region
  dataset_id                 = "resources"
  labels                     = { "level" : "resources" }
  delete_contents_on_destroy = true
  depends_on                 = [google_bigquery_connection.tagging]
}

resource "google_bigquery_routine" "routine_deploy_functions" {
  dataset_id   = google_bigquery_dataset.resources.dataset_id
  routine_id   = "deploy_${var.function_name}"
  routine_type = "PROCEDURE"
  language     = "SQL"
  definition_body = templatefile(var.deployment_procedure_path,
    {
      project            = var.project_id
      dataset            = google_bigquery_dataset.resources.dataset_id
      function_name      = "remote_${var.function_name}"
      region             = var.region
      connection_name    = google_bigquery_connection.tagging.connection_id
      cloud_function_url = google_cloudfunctions2_function.function.service_config[0].uri
    }
  )
  depends_on = [google_bigquery_dataset.resources]
}

## generate a random string suffix for the bq job
resource "random_string" "random" {
  length  = 16
  special = false
}

## Run a BQ job to deploy the remote functions
resource "google_bigquery_job" "deploy_remote_functions_job" {
  job_id   = "d_job_${google_bigquery_routine.routine_deploy_functions.routine_id}_${random_string.random.result}"
  location = var.region

  query {
    priority           = "INTERACTIVE"
    query              = "CALL ${google_bigquery_dataset.resources.dataset_id}.${google_bigquery_routine.routine_deploy_functions.routine_id}();"
    create_disposition = "" # must be set to "" for scripts
    write_disposition  = "" # must be set to "" for scripts
  }
  depends_on = [google_bigquery_routine.routine_deploy_functions]
}

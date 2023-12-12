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
  roles = [
    "roles/bigquery.user",
    "roles/bigquery.dataEditor",
    "roles/bigquery.connectionUser",
    "roles/secretmanager.secretAccessor",
    "roles/storage.objectViewer"
  ]
}

resource "google_secret_manager_secret" "secret" {
  provider  = google-beta
  project   = var.project_id
  secret_id = var.dataform_secret_name

  replication {
    user_managed {
      replicas {
        location = var.location
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  provider = google-beta
  secret   = google_secret_manager_secret.secret.id

  secret_data = var.dataform_remote_repository_token
  depends_on  = [google_secret_manager_secret.secret]
}

resource "google_dataform_repository" "dataform_repository" {
  provider        = google-beta
  project         = var.project_id
  name            = var.dataform_repository_name
  region          = var.location
  service_account = var.dataform_service_account

  git_remote_settings {
    url                                 = var.dataform_remote_repository_url
    default_branch                      = var.dataform_remote_repository_branch
    authentication_token_secret_version = google_secret_manager_secret_version.secret_version.id
  }
  depends_on = [google_secret_manager_secret_version.secret_version]
}

resource "google_dataform_repository_iam_binding" "binding" {
  provider   = google-beta
  project    = google_dataform_repository.dataform_repository.project
  region     = google_dataform_repository.dataform_repository.region
  repository = google_dataform_repository.dataform_repository.name
  role       = "roles/editor"
  members = [
    "${var.editors}"
  ]
}

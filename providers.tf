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

# provider "google" {
#   alias = "service_account"
#   scopes = [
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }

# data "google_service_account_access_token" "default" {
#   provider               = google.service_account
#   target_service_account = "${var.terraform_sa}@${var.project_id}.iam.gserviceaccount.com"
#   scopes = [
#     "userinfo-email",
#     "cloud-platform"
#   ]
#   lifetime = "3600s"
# }

# provider "google" {
#   project = var.project_id
#   region  = var.region

#   access_token    = data.google_service_account_access_token.default.access_token
#   request_timeout = "60s"
# }

# provider "google-beta" {
#   project = var.project_id
#   region  = var.region

#   access_token    = data.google_service_account_access_token.default.access_token
#   request_timeout = "60s"
# }

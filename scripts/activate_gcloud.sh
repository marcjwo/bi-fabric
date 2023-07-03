#!/bin/bash
# **
# * Copyright 2023 Google LLC
# *
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# *      http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# *

# set -e

echo "Activating gcloud account for the project..."
sleep 2
if gcloud config configurations create $CONFIG ; then
    echo "Config created"
else
    echo "Config not created new, already existing"
fi
sleep 1 
gcloud config set project $PROJECT_ID
echo "Project set"
sleep 1 
gcloud config set account $ACCOUNT
echo "Account set"
sleep 1 
gcloud config set compute/region $REGION
echo "Region set"
sleep 2
# echo "Make sure the right project is set by using the command gcloud config list"
# sleep 2
echo "Please continue with authenticating gcloud using the following two commands:"
sleep 1
echo "STEP 1: gcloud auth login --project $PROJECT_ID"
sleep 1
echo "STEP 2: gcloud auth application-default login --project $PROJECT_ID"
sleep 
echo "After successful authentication, continue with terraform"
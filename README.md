# Readme

Hello and welcome to Cloud BI Fabric

## Description and Goals

Cloud BI Fabric helps to set up and deploy a structured cloud data platform that serves the need to implement Business Intelligence on top of it.

This project/repository provides a boilerplate code asset that enables users to deploy a minimal cloud data platform that is ready to be consumed by business intelligence tools and already included in other areas of the cloud platform: data governance, data catalog, etc.
The goal is, to help users jump the first hurdle of setting something seemingly complicated up, see how it works and then enhance the given solution according to their needs.
If wanted, this also comes with a example dataform repository built on top of the `thelook_ecommerce` dataset.

## Requirements

For this asset to work, the following things are required:

- a Google Cloud Project with billing activated
- a Google Cloud Bucket used to store the Terraform state file (will be created)
- a service account that is used to run terraform and can be impersonated by the account used (will be created)
- the right APIs activated

## How to use

Before we start, we need to set a few env variables in the terminal(do not c&p the dollar sign):

```
$ export PROJECT_ID=<Your GCP Project>
$ export ACCOUNT=<Your Account>
$ export TERRAFORM_SA=<The name of the service account to be used for Terraform>
$ export REGION=<Your region>
$ export TF_BUCKET=$PROJECT_ID-terraform
```

Next up, authenticate into Gcloud (please note, both these require confirmation in a browser window):

```
gcloud auth login --project $PROJECT_ID
gcloud auth application-default login --project $PROJECT_ID
```

You can confirm that it has worked by checking `gcloud config list` and making sure that the information matches whats expected.

After that, we need to activate the required APIs, create the terraform account that is going to be used to run terraform, and the GCS bucket to store the state file.

```
$ ./getting_started/enable_required_apis.sh
$ ./getting_started/create_terraform_service_account.sh
$ ./getting_started/create_terraform_state_bucket.sh
```

Finally, we need to create a \*.tfvars to let terraform know what to deploy:

```
project_id                        = <Your Project ID
data_levels                       = <Your desired data levels, e.g. ["source", "intermediate", "output"]>
data_domains                      = <Your desired domains of data, e.g. ["orders", "web"]>
dataform_repository_name          = <Your dataform repository name>
dataform_remote_repository_url    = <Link to Dataform Repository> If you want to try out the demo: "https://github.com/marcjwo/thelook_dataform"
dataform_remote_repository_token  = <Your Github access token to be used by dataform. Follow instructions here:(https://cloud.google.com/dataform/docs/connect-repository)>
dataform_secret_name              = <Secret where the token is stored>
dataform_remote_repository_branch = <Branch name, typically main>
region                            = <Your cloud region>

# Below, the variable to create tag_templates - these follow a specific format, an example is below. This example can be used and is in line with the tagging function thats being deployed with the platform.

tag_templates = [{
  id           = "tag_template1"
  display_name = "tag_template1"
  force_delete = true
  fields = [{
    order       = 1
    id          = "data_owner"
    type        = "STRING"
    is_required = true
    }, {
    id           = "data_level"
    display_name = "Data Level"
    order        = 3
    type         = "ENUM"
    values = [
      "source",
      "intermediate",
      "output"
    ]
    is_required = true
    },
    {
      order       = 2
      id          = "data_domain"
      type        = "STRING"
      is_required = true
    }
  ]
}]
```

_Important note:_ The tag template here goes 🤝 hand in hand with the cloud function thats being deployed and can be found under `./functions/tagging`.

Finally, we can start the deploying:

```
$ terraform init
$ terraform plan
$ terraform apply -var-file=<yourvarfile.tfvars> (This arg can be avoided by calling the file terraform.tfvars)
```

## Whats being deployed?

TBD

## How does this work?

TBD

For demonstrating purposes, see schema below.

- Define data domains to separate data products by domain
  - Every data domain gets a separate data lake
  - Enables finer permission setting
- Define data levels to define layers of data
  - This simplifies the identification of the state of data
  - Every layer equals one zone

![](./assets/BIIAB.png)

# Azure Hub WAAP solution

<!-- spell-checker: ignore volterra markdownlint tfvars -->
This solution will create an Azure hub and spoke network with XC services in the Hub Vnet

<!-- markdownlint-disable no-inline-html -->
<p align="center">Figure 1: High-level overview of solution</p>
<!-- markdownlint-enable no-inline-html -->

BU1 deploys apps as VM's in their spoke VNET
BU2 deploys apps in AKS in their Spoke VNET
XC CE is deployed in the Hub VNET to provide security and delivery services 


## Prerequisites

### Azure

Cloud Credentials, awsLocation
- Reference [Create Azure Service Principal](azure/README.md#login-to-azure-environment)


## Usage example

- Clone the repo and open the solution's directory
```bash
git clone https://github.com/
cd azure-hub-xc
```


- Set Volterra environment variables
- Create a Volterra credentials p12 file and copy it to a local folder. Follow steps here - https://www.volterra.io/docs/how-to/user-mgmt/credentials

```bash
export VES_P12_PASSWORD="your_key"
export VOLT_API_URL="https://<tenant-name>.console.ves.volterra.io/api"
export VOLT_API_P12_FILE="/var/tmp/<example>.console.ves.volterra.io.api-creds.p12"
```

- Get the Volterra tenant name
General namespace in the VoltConsole UI, then Tenant Settings > Tenant overview

- Create the tfvars file and update it with your settings

```bash
cp admin.auto.tfvars.example admin.auto.tfvars
# MODIFY TO YOUR SETTINGS
vi admin.auto.tfvars
```

terraform apply 
export KUBECONFIG=$KUBECONFIG:./aks-cluster-config


## TEST your setup:


## Cleanup
Use the following command to destroy all of the resources

destroy the environment:

```bash
terraform destroy
```


<!-- markdownlint-disable no-inline-html -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14.5 |
| volterra | 0.11.4 |

## Providers

| Name | Version |
|------|---------|
| random | n/a |
| volterra | 0.11.4 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) |
| [volterra_virtual_site](https://registry.terraform.io/providers/volterraedge/volterra/0.11.4/docs/resources/virtual_site) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | The Volterra namespace into which Volterra resources will be managed. | `string` | n/a | yes |
| volterraTenant | The Volterra tenant to use. | `string` | n/a | yes |
| awsRegion | aws region | `string` | `null` | no |
| azureLocation | location where Azure resources are deployed (abbreviated Azure Region name) | `string` | `null` | no |
| buildSuffix | unique build suffix for resources; will be generated if empty or null | `string` | `null` | no |
| domain\_name | The DNS domain name that will be used as common parent generated DNS name of<br>loadbalancers. Default is 'shared.acme.com'. | `string` | `"shared.acme.com"` | no |
| gcpProjectId | gcp project id | `string` | `null` | no |
| gcpRegion | region where GCP resources will be deployed | `string` | `null` | no |
| projectPrefix | prefix for resources | `string` | `"mcn-demo"` | no |
| resourceOwner | owner of the deployment, for tagging purposes | `string` | `"f5-dcec"` | no |
| ssh\_key | An optional SSH key to add to nodes. | `string` | `""` | no |
| volterraCloudCredAWS | Volterra Cloud Credential to use with AWS | `string` | `null` | no |
| volterraCloudCredAzure | Volterra Cloud Credential to use with Azure | `string` | `null` | no |
| volterraCloudCredGCP | Volterra Cloud Credential to use with GCP | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| buildSuffix | build suffix for the deployment |
| volterraVirtualSite | name of virtual site across all clouds |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->

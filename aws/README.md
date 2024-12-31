# AWS Terraform Module

This module deploys a SecureKey VPN VM instance on AWS.

## Usage
Ensure you have configured your AWS credentials correctly by either configuring `aws-cli` 
or setting your environment variables (`AWS_SHARED_CREDENTIALS_FILE`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN`).

To plan your deployment, execute:


```
export AWS_SHARED_CREDENTIALS_FILE=~/.aws/credentials
terraform plan --var-file <YOUR_VAR_FILE.tfvars>
```

To apply:
```
export AWS_SHARED_CREDENTIALS_FILE=~/.aws/credentials
terraform apply --var-file <YOUR_VAR_FILE.tfvars>

```


## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | The Region in which to provision resources. | `string` | `us-west-2` | no |
| availability_zone | The Availability Zone in which to provision resources. | `string` | `"us-west-2a"` | no |
| ssh_pub_key_file | The path to the SSH public key file. | `string` | `"create"` | no |
| key_name | The SSH key name to use. | `string` | `""` | no |
| aws_instance_name | The name of the deployment and VM instance. | `string` | `"aws-securekey-vm"` | no |
| vpc_name | The VPC to launch the instance into. | `string` | `""` | no |
| vpc_cidr | The VPC CIDR to use. | `string` | `"10.0.0.0/16"` | no |
| product_id | The product ID for the deployment. | `string` | `"/aws/service/marketplace/prod-7anczd5r647ng/v2.2"` | no |
| instance_type | The machine type to create. | `string` | `""` | yes |


## Outputs

| Name | Description |
|------|-------------|
| admin_url | The Admin URL for accessing the compute instance. |
| instance_id | The ID of the compute instance. |
| region | The region where the compute instance is deployed. |
| ami_id | The AMI ID used for the compute instance. |
| instance_type | The type of compute instance. |
| mgmt_elastic_ip | The external IP address of the management interface. |
| wan_elastic_ip | The external IP address of the WAN interface. |
| vpc_id | The ID of the VPC where the compute instance is deployed. |
| ssh_key | The SSH private key for the instance. |

## Requirements
### Terraform

Be sure you have the correct Terraform version (1.2.0+), you can choose the binary here:

https://releases.hashicorp.com/terraform/



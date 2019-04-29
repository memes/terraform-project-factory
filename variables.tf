# The project id to use, to which a random suffix will be appended to avoid
# collision in the global namespace.
variable "project_id" {
  type = "string"

  description = <<EOF
REQUIRED.
The project id to use for this project; a random suffix will be added to the
value to avoid collision with an existing project_id, and the resulting string
will be truncated to 30 chars max. The value must match /[a-z][-a-z0-9]+/.

E.g. project_id = "foo-bar" will become something like
generated project_id = "foo-bar-213e2a3c"
EOF
}

# Set to true to disable project randomisation - useful when importing existing
# projects into the module.
variable "randomise_project_id" {
  description = <<EOF
If set to false, the project_id will not contain a random suffix; defaults to
true. E.g. to import an existing project into terraform workspace using this
module,
randomise_project_id = false
EOF

  default = true
}

# The project display name to use. This can contain any characters.
variable "display_name" {
  type = "string"

  description = <<EOF
The display name to use for the project. Default is an empty string.
EOF

  default = ""
}

# The domain name associated with the organization
variable "org_domain_name" {
  type = "string"

  description = <<EOF
REQUIRED.
The domain name associated with the organization into which this project will
be inserted. E.g. neudesic.com
EOF
}

# The billing account name
variable "org_billing_name" {
  type = "string"

  description = <<EOF
REQUIRED.
The display name of the billing account to associate with this project. This
can be found in consule UI for billing, or by executing
`gcloud beta billing accounts list --format='value(displayName)'`
EOF
}

# Folder id; Terraform does not have an easy way to find a nested folder id
# from a name, so request the unique folder id.
variable "folder_id" {
  type = "string"

  description = <<EOF
If not empty, the project will be created within the folder that is uniquely
identified by this value. Defaults to '' to create project in root of
organization.
EOF

  default = ""
}

variable "is_shared_vpc_host" {
  description = <<EOF
If set to true, the project will be created as a shared VPC host project.
Defaults to false.
EOF

  default = false
}

variable "shared_vpc_host_project_id" {
  type = "string"

  description = <<EOF
If `shared_vpc_host_project_id` is not empty and a valid project identifier,
the new project will be created as a shared VPC service project, attached to
the host specified by this value.
EOF

  default = ""
}

variable "networks" {
  type = "list"

  description = <<EOF
A list of network names to create in the project, defaults to an empty list.
EOF

  default = []
}

variable "subnets" {
  type = "list"

  description = <<EOF
A list of network:region:CIDR (or network:region:CIDR:name:enable_private)
definitions to use for creating subnetworks. If a name for the subnet is not
provided, one will be generated by concatenating network name and region, separated by hyphens. An optional `enable_private` flag can be used to
enable/disable private IP access on the subnet; the flag defaults to false.

E.g. subnets = ["prod:us-west1:192.168.0.0/24:dmz", "prod:us-east1:192.168.1.0/24"]
will create two subnets in `prod` network, in us-west1 and us-east1, with CIDRs
192.168.0.0/24 and 192.168.1.0/24 respectively. The name of the subnet in
us-west1 will be 'dmz', and us-east1 will be `prod-us-east1` as there wasn't a
specific name provided.
EOF

  default = []
}

variable "network_admins" {
  type = "list"

  description = <<EOF
A list of accounts (service account, user, or group) that will be granted the
compute.networkAdmin role on shared VPC host projects. Default is an empty
list.

E.g. network_admins = [
  "serviceAccount:abc@example.com",
  "user:alice@example.com",
  "group:admins@example.com"
]
EOF

  default = []
}

variable "network_users" {
  type = "list"

  description = <<EOF
A list of accounts (service account, user, or group) that will be granted the
compute.networkUser role on shared VPC host projects. Default is an empty list.

E.g. networkUusers = [
  "serviceAccount:abc@example.com",
  "user:bob@example.com",
  "group:users@example.com"
]
EOF

  default = []
}

variable "service_account_ids" {
  type = "list"

  description = <<EOF
An optional list of service account id's to create in the the project.
Defaults to an empty list.

E.g. service_account_id = ["foobar", "baz"] in project "abc-foo" will create
service accounts with emails foobar@abc-foo-XXXXXX.iam.gserviceaccount.com
and baz@abc-foo-XXXXXX.iam.gserviceaccount.com.
EOF

  default = []
}

variable "service_account_subnets" {
  type = "list"

  description = <<EOF
A mapping of service accounts (email addresses) to subnets for which the
service account will be allowed to connect. Defaults to an empty list, which
allows all service accounts created from `service_account_ids` variable to
have access to all subnets in host (or this) project.

The subnets *must* be specified as a list of region:name pairs, as terraform
must provide a region as part of the association to service account. You can
get the list of region:pairs in a host project created by these series of
modules by getting the output of 'subnets' from the host project workspace.

E.g.
service_account_subnets = [] =>
  all service accounts can bind to any subnet of the service host project

service_account_subnets = [ "foobar@example.com:us-west1:bar"] =>
  service account 'foobar' can only bind to 'bar' subnet in region 'us-west1'
  of network as defined in the service host project. Any other service accounts
  will not have permissions to join a network.
EOF

  default = []
}

variable "service_account_subnets_count" {
  default = 0

  description = <<EOF
When passing a list of service account:subnets as part of a shared VPC, you must explicitly set the number of entries in the list to work around a Terraform limitation.

E.g.
service_account_subnets = ["foobar@example.com:us-west1:bar"]
service_account_subnets_count = 1
EOF
}

variable "iam_assignments" {
  type = "list"

  description = <<EOF
A list of accounts (service account, user, or group) that will be granted a
named role on project. List is formatted as account=role. Defaults to an empty
list.

E.g. iam_assigments = [
  "serviceAccount:abc@example.com=roles/editor",
  "user:bob@example.com=roles/viewer",
  "group:users@example.com=roles/owner"
]
EOF

  default = []
}

variable "iam_assignments_count" {
  default = 0

  description = <<EOF
When passing a list of account:roles as `iam_assignments`, you must explicitly set the number of entries in the list to work around a Terraform limitation.

E.g.
iam_assignments = ["user:foobar@example.com=roles/editor"]
iam_assignments_count = 1
EOF
}

# A list of APIs to enable on the project
variable "enable_apis" {
  type = "list"

  description = <<EOF
A list of APIs to enable in the project. Defaults to an empty list.

E.g. enable_apis = ["container.googleapis.com"] to enable use of GKE.
EOF

  default = []
}

# Delete default service account?
variable "delete_default_service_account" {
  type = "string"

  description = <<EOF
If true, the default service account will be deleted during project creation.
Defaults to true, as this is the recommendation of Neudesic.
EOF

  default = "true"
}

# Should the default network be deleted when the project is created
variable "auto_create_network" {
  type = "string"

  description = <<EOF
If set to false, which is the recommended and default value, the 'default'
network will be destroyed as part of project creation. If set to true, the
'default' network will remain as part of project creation.

Default value is false.
EOF

  default = "false"
}

# If set to a valid bucket name, usage data will be exported to it as
# CSV files. Recommended, but optional.
variable "usage_export_bucket" {
  type = "string"

  description = <<EOF
The name of a bucket to use for usage reporting. Daily and monthly
usage reports for the project will be exported as CSV files into
this bucket, in a folder named 'usage-project_id'. If left empty,
then a project bucket will be automatically created and used for usage exports.
Default value is an empty string.

E.g.
project_id = "foobar"
usage_export_bucket = "billing_data"

will result in daily CSVs being stored as
'gs://billing_data/usage-foobar-XXXXXX_gcs_YYYYMMDD.csv'

project_id = "foobar"
usage_export_bucket = "" (default)

will result in daily CSVs being stored as
'gs://foobar-XXXXXX/usage-foobar-XXXXXX_gcs_YYYYMMDD.csv'
EOF

  default = ""
}

# Location to use when automatically creating a usage export bucket for the
# project
variable "usage_export_bucket_location" {
  type = "string"

  description = <<EOF
The location to use if a bucket is automatically created to contain usage
export files for the project. Must be one of the supported multi-regional
buckets ('ASIA', 'EU', or 'US' at time of writing). Default is 'US'.
EOF

  default = "US"
}

# Service account credentials
variable "terraform_credentials" {
  type = "string"

  description = <<EOF
File that contains the terraform service account credentials for supporting
scripts. Default is an empty string.
EOF

  default = ""
}

variable "labels" {
  type    = "map"
  default = {}

  description = <<EOF
A map of key-value pairs to attach as labels to all resources that accept them. Default is an empty set.

E.g. to label all resources with 'customer' value,

labels = {
  "customer" = "name"
}
EOF
}

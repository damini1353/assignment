variable "project_id" {
    type = string
}

variable "bucket_name" {
    type = string
}

variable "bucket_region" {
    type = string
}

variable "user_name" {
    type = string
}

variable "vpc_network_name" {
    type = string
}

variable "subnet_1_name" {
    type = string
}

variable "subnet_1_ip_cidr" {
    type = string
}

variable "subnet1_region" {
    type = string
}

variable "subnet_2_name" {
    type = string
}

variable "subnet_2_ip_cidr" {
    type = string
}

variable "subnet2_region" {
    type = string
}

variable "subnet_3_name" {
    type = string
}

variable "subnet_3_ip_cidr" {
    type = string
}

variable "subnet3_region" {
    type = string
}

variable "default_route_subnet1_name" {
    type = string
}

variable "default_route_subnet2_name" {
    type = string
}

variable "default_route_subnet3_name" {
    type = string
}

variable "sql_db_name" {
    type = string
}

variable "database_version" {
    type = string
}

variable "sql_region" {
    type = string
}

variable "db_tier"{
    type = string
}

variable "disk_size" {
    type = string
}

variable "sql_database_name" {
    type = string
}

variable "secret_id" {
    type = string
}

variable "cloud_nat_name" {
    type = string
}
variable "min_ports_per_vm" {
    type = number
}
variable "cloud_router_name" {
    type = string
}

variable "machine_type"{
    type = string
}
variable "network_tags"{
    type = list(string)
}
variable "allow_stopping_for_update"{
    type = string
}
variable "deletion_protection"{
    type = bool
}
variable "image"{
    type = string
}
variable "boot_disk_size_gb"{
    type = string
}
variable "boot_disk_type"{
    type = string
}
variable "boot_disk_labels"{
    type = string
}
variable "boot_disk_auto_delete"{
    type = bool
}
variable "attached_disk"{
    type = list(string)
}
variable "network"{
    type = string
}
variable "subnetwork"{
    type = string
}
variable "subnetwork_project"{
    type = string
}
variable "metadata"{
    type = map(string)
}
variable "startup_script"{
    type = string
}
variable "sa_email"{
    type = string
}
variable "enable_secure_boot"{
    type = bool
}
variable "labels"{
    type = map(string)
}
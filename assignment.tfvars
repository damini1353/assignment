project_id = "prj-demo"
bucket_name = "demo-bkt"
bucket_region = "us-east4"
user_name = "user:user_email@org.com"
vpc_network_name = "demo-vpc"
subnet_1_name = "demo-vpc-sb-1"
subnet_1_ip_cidr = "10.0.0.2/20"
subnet1_region = "us-west1"
subnet_2_name = "demo-vpc-sb-2"
subnet_2_ip_cidr = "10.2.3.0/20"
subnet2_region = "us-east4"
subnet_3_name = "demo-vpc-sb-3"
subnet_3_ip_cidr = "10.0.0.56/20"
subnet3_region = "us-central1"
default_route_subnet1_name = "df-route-sb-1"
default_route_subnet2_name = "df-route-sb-2"
default_route_subnet3_name = "df-route-sb-3"
sql_db_name = "demo-sql-instance"
database_version = "MYSQL_8_0"
sql_region = "us-central1"
db_tier = "db-f1-micro"
disk_size = "100"
sql_database_name = "test-db"
secret_id = "secret-root-pwd"

cloud_nat_name = "nat-vpc"
min_ports_per_vm = 64
cloud_router_name = "router-nat-demo"


machine_type = "n2-standard-4"
network_tags = ["allow-proxy"]
allow_stopping_for_update = true
deletion_protection = false
image = "os-type-public-url"
boot_disk_size_gb = "100"
boot_disk_type = "pd-balanced"
boot_disk_labels = {
    "appname" = "ngnix"
    "owner" = "gcp-admins"
}
boot_disk_auto_delete = true
attached_disk = [
    {
        source = "source_disk_uri"
    }
]
instance_network = "demo-vpc"
instance_subnetwork = "demo-vpc-sb-1"
subnetwork_project = "prj-demo"
metadata = {
    os-login = true
}
startup_script = "#bin/bash"
sa_email = "sa_project_id@gserviceaccount.com"
enable_secure_boot = true
labels = {
    "appname" = "ngnix"
    "owner" = "gcp-admins"
}

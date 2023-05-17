##	Create a GCP storage bucket
resource "google_storage_bucket" "name_of_bucket" {
  project       = var.project_id
  name          = var.bucket_name
  location      = var.bucket_region 
  force_destroy = true
  public_access_prevention = "enforced"
}
##	Apply a policy to the bucket allowing only read access
resource "google_storage_bucket_iam_binding" "binding" {
  bucket = google_storage_bucket.name_of_bucket.name
  role = "roles/storage.objectViewer"
  members = [
    var.user_name,
  ]
}

##	Create VPC with 3 subnets
resource "google_compute_network" "default" {
  project      = var.project_id
  network_name = var.vpc_network_name
  mtu          = 1460
##Create 3 Subnets
  resource "google_compute_subnetwork" "subnet1" {
      name = var.subnet_1_name
      ip_cidr_range = var.subnet_1_ip_cidr
      region = var.subnet1_region
      network = google_compute_network.vpc_network.self_link
    }
  resource "google_compute_subnetwork" "subnet2" {
      name = var.subnet_2_name
      ip_cidr_range = var.subnet_2_ip_cidr
      region = var.subnet2_region
      network = google_compute_network.vpc_network.self_link
    }
  resource "google_compute_subnetwork" "subnet3" {
      name = var.subnet_3_name
      ip_cidr_range = var.subnet_3_ip_cidr
      region = var.subnet3_region
      network = google_compute_network.vpc_network.self_link
    }
}

#Create Default route for each subnet
   resource "google_compute_route" "default_route_subnet1" {
       name = var.default_route_subnet1_name
       network = ""
       dest_range = "0.0.0.0/0"
       next_hop_ip = null
       next_hop_instance = null
       next_hop_network = google_compute_network.self_link
   }

   resource "google_compute_route" "default_route_subnet2" {
       name = var.default_route_subnet2_name
       network = ""
       dest_range = "0.0.0.0/0"
       next_hop_ip = null
       next_hop_instance = null
       next_hop_network =google_compute_network.self_link
   }

   resource "google_compute_route" "default_route_subnet3" {
       name = var.default_route_subnet3_name
       network = ""
       dest_range = "0.0.0.0/0"
       next_hop_ip = null
       next_hop_instance = null
       next_hop_network = google_compute_subnetwork.subnet3.self_link
   }

#Create 1 Internet gateway

module "cloud_nat" {
  source                              = "terraform-google-modules/cloud-nat/google"
  version                             = "2.2.1"
  name                                = var.cloud_nat_name
  project_id                          = var.project_id
  region                              = var.region
  router                              = module.cloud_router_nat.router.name
  min_ports_per_vm                    = var.min_ports_per_vm
  source_subnetwork_ip_ranges_to_nat  = var.source_subnetwork_ip_ranges_to_nat
  enable_endpoint_independent_mapping = false
  nat_ips                             = module.cloud_nat_external_static_ip_reserve.self_links
}


module "cloud_router_nat" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "3.0.0"
  name    = var.cloud_router_name
  project = var.project_id
  region  = var.region
  network = google_compute_network.default.network_name
}

module "cloud_nat_external_static_ip_reserve" {
  source       = "terraform-google-modules/address/google"
  version      = "3.1.1"
  project_id   = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  names = [
    "nat-us-east4-1",
    "nat-us-east4-2",
    "nat-us-east4-3"
  ]
  enable_cloud_dns = false
}

#Create security groups for each subnet

module "firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  version                 = "5.1.0"
  project_id              = var.project_id
  network                 = google_compute_network.default.network_name
  internal_ranges_enabled = false
  internal_ranges         = []
  internal_target_tags    = []
  ssh_source_ranges       = []
  ssh_target_tags         = []
  https_target_tags       = []
  https_source_ranges     = []
  http_source_ranges      = []
  custom_rules = {
    fw-65000-egress-deny-all = {
      description          = "Override default allow all ports egress rule"
      direction            = "EGRESS"
      action               = "deny"
      ranges               = ["X.X.X"]
      use_service_accounts = false
      rules = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      sources = []
      targets = []
      extra_attributes = {
        priority           = 65000
        flow_logs          = true
        flow_logs_metadata = "INCLUDE_ALL_METADATA"
      }
    }

    fw-egress-allow-all = {
      description          = "Allows for internal VPC communication"
      direction            = "EGRESS"
      action               = "allow"
      ranges               = [X.X.X.X/X]
      use_service_accounts = false
      rules = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      sources = []
      targets = []
      extra_attributes = {
        priority           = 1000
        flow_logs          = true
        flow_logs_metadata = "INCLUDE_ALL_METADATA"
      }
    }
}
}
##Create Cloud sql instance
resource "google_sql_database_instance" "instance_name" {
project = var.project_id
name = var.sql_db_name
database_version = var.database_version
region = var.sql_region
settings {
tier = var.db_tier
disk_size = var.disk_size
backup_configuration {
  enabled = true
  start_time = "17:00"
}
}
}

##Cloud SQL Database
resource "google_sql_database" "database" {
name = var.sql_database_name
instance = "${google_sql_database_instance.instance.name}"
charset = "utf8"
collation = "utf8_general_ci"
}

##Cloud SQL User
resource "google_sql_user" "users" {
name = "root"
instance = "${google_sql_database_instance.instance.name}"
host = "%"
password = data.google_secret_manager_secret_version.dbserver_db_root_pwd.secret_data
}

resource "google_secret_manager_secret" "secret-db" {
  project                   = var.project_id
  secret_id = var.secret_id
    replication {
    user_managed {
      replicas {
        location = var.secret_manager_region
      }
      replicas {
        location = var.replica_region
      }
    }
  }
}

data "google_secret_manager_secret_version" "dbserver_db_root_pwd"{
  secret = google_secret_manager_secret.secret-db.secret_id
}


##Create Web Server Instance

resource "google_compute_instance" "web_server" {
  project                   = var.project_id
  count                     = 2
  name                      = var.instance_name[count.index]
  machine_type              = var.machine_type
  zone                      = var.zone
  tags                      = var.network_tags
  allow_stopping_for_update = var.allow_stopping_for_update
  deletion_protection       = var.deletion_protection
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
      labels  = var.boot_disk_labels
    }
    auto_delete = var.boot_disk_auto_delete
  }

  dynamic "attached_disk" {
    for_each = var.attached_disk
    content {
      source = lookup(attached_disk.value, "source", null)
    }
  }
  network_interface {
    network            = var.instance_network
    subnetwork         = var.instance_subnetwork
    subnetwork_project = var.subnetwork_project
  }
  metadata                = var.metadata
  metadata_startup_script = var.startup_script

  service_account {
      email  = var.service_account_email
      scopes = "cloud-platform"
    }


  shielded_instance_config {
    enable_secure_boot = var.enable_secure_boot
  }
  labels = var.labels


}

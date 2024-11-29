terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 5.25.0"
    }
  }
}

provider "google" {
  credentials = file("loadbalencer.json")
  project     = "abs-123"
  region      = "us-central1"  # Specify the region for the load balancer
}

resource "google_compute_forwarding_rule" "lb_frontend" {
  name                  = "lb-frontend"
  target                = google_compute_target_pool.lb_target_pool.self_link
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_target_pool" "lb_target_pool" {
  name = "lb-target-pool"

  health_checks = [google_compute_http_health_check.lb_health_check.self_link]
}

resource "google_compute_http_health_check" "lb_health_check" {
  name               = "lb-health-check"
  check_interval_sec = 1
  timeout_sec        = 1
  healthy_threshold  = 1
  unhealthy_threshold = 2
  port               = 80
  request_path       = "/healthz"
}

resource "google_compute_instance_group" "instance_group" {
  name        = "instance-group"
  zone        = "us-central1-a"
  description = "Instance group for load balancing"
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_instance_template" "lb_instance_template" {
  name        = "lb-instance-template"
  description = "Instance template for load balancer instances"
  machine_type = "n1-standard-1"  # Specify the machine type for the instances
  
  disk {
    source_image = "ubuntu-2004-focal-v20240209"
    disk_size_gb = 10
    disk_type = "pd-standard"
  }
  
  network_interface {
    network = "default"
  }
}

resource "google_compute_firewall" "lb_firewall" {
  name    = "lb-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.34.0"
    }
  }
}
provider "google" {
  credentials = file("stryra-88c7c6b46544.json") # Archivo de credenciales
  project = "stryra" # ID de mi proyecto
  region = "southamerica-east1"
}

resource "google_compute_instance" "vm_ejemplo" {
  name         = "terraform-vm"
  machine_type = "e2-micro"
  zone         = "southamerica-east1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

}
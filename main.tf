terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.34.0"
    }
  }
}
provider "google" {
  # credentials = file("stryra-88c7c6b46544.json") # Archivo de credenciales
  project = "stryra" # ID de mi proyecto
  region = "southamerica-east1"
}

# 2.- crear una red VPC (Virtual Private Cloud)
resource "google_compute_network" "mi_vpc_de_practica" {
  name = "mi-red-vpc-terraform" # nombre unico para mi red
  auto_create_subnetworks = false # gcp no creara subredes automaticamente
}

# 3.- crear una subred dentro de mi VPC
resource "google_compute_subnetwork" "mi_subred_de_practica" {
  name = "mi-subred-de-practica" # nombre unico para la subred
  ip_cidr_range = "10.1.0.0/24" # rango de ips para esta subred (10.0.1.1 a 10.0.1.254)
  region = "southamerica-east1" # debe estar en la misma region que mi proveedor
  network = google_compute_network.mi_vpc_de_practica.self_link # conecta la rubred con la VPC
}

# 4.- crear una regla firewall para permitir SSH
resource "google_compute_firewall" "permitir_ssh" {
  name = "permitir-ssh-terraform" # nombre para la regla de firewall
  network = google_compute_network.mi_vpc_de_practica.self_link # aplica la regla a mi VPC

  allow {
    protocol = "tcp" # permitir protocolo TCP
    ports = ["22"] # el puerto 22 (puerto estandar pára SSH)
  }

  source_ranges = ["0.0.0.0/0"] # permitir conexiones desde cualquier IP (en produccion seria mi IP)
  target_tags = ["web-server"] # aplica la regla a las VMs que tengan la etiqueta "web-server"
}

# 5.- crear una maquina virtual (VM)
resource "google_compute_instance" "mi_servidor_web" {
  name = "mi-servidor-web-terraform" # nombre de la maquina
  machine_type = "e2-micro" # tipo de maquina pequeña y barata
  zone = "southamerica-east1-a" # zona especifica dentro de la region

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # sistema operativo
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mi_subred_de_practica.self_link # conecta la maquina a mi subred

    access_config {
      # esto da una ip publica a mi maquina para poder acceder desde internet
    }
  }

  tags = ["web-server"] # asigna la etiqueta "web-server" a esta maquina para que la regla de firewall le afecte
}

# 6.- mostrar la IP publica de mi maquina
output "ip_publica_servidor_web" {
  value = google_compute_instance.mi_servidor_web.network_interface[0].access_config[0].nat_ip
  description = "La ip publica de mi servidor web para poder conectarse por SSH."
}
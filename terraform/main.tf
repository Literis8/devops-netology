resource "yandex_compute_instance" "netology" {
  name = "netology"
  platform_id = local.platform_id_type[terraform.workspace]
  count = local.instance_count[terraform.workspace]
  lifecycle {
    create_before_destroy = true
  }
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80d7fnvf399b1c207j"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.my-subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "for-each" {
  name = "for-each"
  for_each = local.instances
  platform_id = each.key
  lifecycle {
    create_before_destroy = true
  }
  boot_disk {
    initialize_params {
      image_id = each.value
    }
  }
  network_interface {
    subnet_id = "yandex_vpc_subnet.my-subnet.id"
    nat       = true
  }
  resources {
    cores  = 2
    memory = 2
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
resource "yandex_vpc_network" "my-network" {
  name = "my-network"
}

resource "yandex_vpc_subnet" "my-subnet" {
  name           = "my-subnet"
  zone           = var.YC_ZONE
  network_id     = yandex_vpc_network.my-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

locals {
  platform_id_type = {
    stage = "standard-v2"
    prod = "standard-v1"
  }
  instance_count = {
    stage = "1"
    prod = "2"
  }
  instances = {
    "standard-v2" = "fd80d7fnvf399b1c207j"
    "standard-v1" = "fd80d7fnvf399b1c207j"
  }
}

output "internal_ip_address_netology_vm" {
  value = yandex_compute_instance.netology.*.network_interface.0.ip_address
}

output "external_ip_address_netology_vm" {
  value = yandex_compute_instance.netology.*.network_interface.0.nat_ip_address
}

output "internal_ip_address_for-each" {
  value = values(yandex_compute_instance.for-each).*.network_interface.0.ip_address
}

output "external_ip_address_for-each" {
  value = values(yandex_compute_instance.for-each).*.network_interface.0.nat_ip_address
}

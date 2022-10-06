resource "yandex_compute_instance" "nginx" {
  name = "nginx-${terraform.workspace}"
  hostname = "nginx-${terraform.workspace}"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image_id = "fd80d7fnvf399b1c207j"
    }
  }
  network_interface {
    subnet_id = local.subnet_id[terraform.workspace]
    nat       = true
    nat_ip_address = local.public_ip[terraform.workspace]
    ip_address = "${local.subnet_ip[terraform.workspace]}100"
  }
  resources {
    cores  = 2
    memory = 2
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "db01" {
  name = "db01"
  hostname = "db01.literis.ru"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image_id = "fd8f1tik9a7ap9ik2dg1"
    }
  }
  network_interface {
    subnet_id = local.subnet_id[terraform.workspace]
    nat = false
    ip_address = "${local.subnet_ip[terraform.workspace]}101"
  }
  resources {
    cores  = 4
    memory = 4
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "db02" {
  name = "db02"
  hostname = "db02.literis.ru"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image_id = "fd8f1tik9a7ap9ik2dg1"
    }
  }
  network_interface {
    subnet_id = local.subnet_id[terraform.workspace]
    nat = false
    ip_address = "${local.subnet_ip[terraform.workspace]}102"
  }
  resources {
    cores  = 4
    memory = 4
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "www" {
  name = "www"
  hostname = "www.literis.ru"
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image_id = "fd8f1tik9a7ap9ik2dg1"
    }
  }
  network_interface {
    subnet_id = local.subnet_id[terraform.workspace]
    nat = false
    ip_address = "${local.subnet_ip[terraform.workspace]}103"
  }
  resources {
    cores  = 4
    memory = 4
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

#resource "yandex_vpc_network" "my-network" {
#  name = "my-network"
#}

#resource "yandex_vpc_subnet" "my-subnet" {
#  name           = "my-subnet"
#  zone           = var.YC_ZONE
#  network_id     = yandex_vpc_network.my-network.id
#  v4_cidr_blocks = ["192.168.10.0/24"]
#}

locals {
  public_ip = {
    stage = "62.84.116.251"
    prod = "62.84.116.237"
  }
  subnet_id = {
    stage = "e9bpckaq6oecdh4v0550"
    prod = "e9bk73fbfmdaiuimu8bf"
  }
  subnet_ip = {
    stage = "192.168.20."
    prod = "192.168.10."
  }
}

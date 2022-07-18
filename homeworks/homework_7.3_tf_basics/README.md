# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 

### Решение:
По скольку возможности работать в AWS нет, с помощью 
[этой инструкции](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-state-storage) настраиваем
бакет для хранения стэйтов.

Добавляем зеркало провайдера в `~/.terraformrc`
```
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

В связи с тем что при использовании внешнего бэкенда бакет должен быть уже создан я создаюотдельный файл в проекте 
`terraform/bucket/main.tf`
```terraform
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
  zone      = var.YC_ZONE
}
resource "yandex_storage_bucket" "netology-bucket" {
  access_key = var.SERV_KEY_ID
  secret_key = var.SERV_KEY_SECRET
  bucket = "netology-bucket"
  force_destroy = true
}
```

инициализируем terraform
```shell
vagrant@vagrant:/devops-netology/terraform/bucket$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.76.0...
- Installed yandex-cloud/yandex v0.76.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

Создаем сервисный аккаунт с ролью editor и получаем статический ключ доступа
```shell
root@vagrant:~# yc init
Welcome! This command will take you through the configuration process.
Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb in order to obtain OAuth token.

Please enter OAuth token: *********
You have one cloud available: 'cloud-literis8-netology01' (id = *********). It is going to be used by default.
Please choose folder to use:
 [1] default (id = *********)
 [2] Create a new folder
Please enter your numeric choice: 1
Your current folder has been set to 'default' (id = *********).
Do you want to configure a default Compute zone? [Y/n]
Which zone do you want to use as a profile default?
 [1] ru-central1-a
 [2] ru-central1-b
 [3] ru-central1-c
 [4] Don`t set default zone
Please enter your numeric choice: 1
Your profile default Compute zone has been set to 'ru-central1-a'.

root@vagrant:~# yc iam service-account create --name tf-service
id: *********
folder_id: *********
created_at: "2022-07-03T14:50:35.550670903Z"
name: tf-service

root@vagrant:~# yc resource-manager folder add-access-binding default \
> --role editor \
> --subject serviceAccount:*******
done (2s)

root@vagrant:~# yc iam access-key create --service-account-name tf-service
access_key:
  id: *****
  service_account_id: *****
  created_at: "2022-07-03T14:58:32.510522273Z"
  key_id: *****
secret: *****
```

Создаем файл provider.tf с описанием бэкэнда
```terraform
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "netology-bucket"
    key = "devops-netology/terraform.tfstate"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
  zone      = var.YC_ZONE
}
```

А так же файл для хранени перемнных бэкенда (так как их нельзя использовать в секции backend)
```terraform
access_key = "************"
secret_key = "************"
region = "************"
```

После чего инициируем Terraform для работы с внешним бэкэндом
```shell
vagrant@vagrant:/devops-netology/terraform$ terraform init --backend-config=backend.conf

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of yandex-cloud/yandex from the dependency lock file
- Using previously-installed yandex-cloud/yandex v0.76.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
1. Создайте два воркспейса `stage` и `prod`.
1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
1. При желании поэкспериментируйте с другими параметрами и рессурсами.

### Решение
1. Вывод `terraform init`
```shell
vagrant@vagrant:/devops-netology/terraform$ terraform init --backend-config=backend.conf

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of yandex-cloud/yandex from the dependency lock file
- Using previously-installed yandex-cloud/yandex v0.76.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

2. Создание воркспейсов:
```shell
vagrant@vagrant:/devops-netology/terraform$ terraform workspace new stage
Created and switched to workspace "stage"!

You`re now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

vagrant@vagrant:/devops-netology/terraform$ terraform workspace new prod
Created and switched to workspace "prod"!

You`re now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```
3. Добавим зависимость типов инстансов от воркспейсов:
```terraform
resource "yandex_compute_instance" "netology" {
  name = "netology"
  platform_id = local.platform_id_type[terraform.workspace]
}

locals {
  platform_id_type = {
    stage = "standard-v2"
    prod = "standard-v1"
  }
}
```

4. Добавляем зависимость количества инстансов от воркспейсов так же меняем outputs
```terraform
resource "yandex_compute_instance" "netology" {
   count = local.instance_count[terraform.workspace]
}
locals {
  instance_count = {
    stage = "1"
    prod = "2"
  }
}
output "internal_ip_address_netology_vm" {
  value = yandex_compute_instance.netology.*.network_interface.0.ip_address
}

output "external_ip_address_netology_vm" {
  value = yandex_compute_instance.netology.*.network_interface.0.nat_ip_address
}
```

5. Создаем рядом еще одну группу инстансов через for_each и так же добавляем outputs
```terraform
resource "yandex_compute_instance" "for-each" {
  for_each = local.instances
  platform_id = each.key
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
locals {
  instances = {
    "standard-v2" = "fd80d7fnvf399b1c207j"
    "standard-v1" = "fd80d7fnvf399b1c207j"
  }
}
output "internal_ip_address_for-each" {
  value = values(yandex_compute_instance.for-each).*.network_interface.0.ip_address
}

output "external_ip_address_for-each" {
  value = values(yandex_compute_instance.for-each).*.network_interface.0.nat_ip_address
}
```

6. Добавляем параметры жизненого цикла 
```terraform
resource "yandex_compute_instance" "for-each" { 
  for_each = local.instances
  platform_id = each.key
  lifecycle {
    create_before_destroy = true
  }
}
resource "yandex_compute_instance" "netology" {
  name = "netology"
  platform_id = local.platform_id_type[terraform.workspace]
  count = local.instance_count[terraform.workspace]
  lifecycle {
    create_before_destroy = true
  }
```

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
* Вывод команды `terraform plan` для воркспейса `prod`.  

Вывод команды `terraform workspace list`
```shell
vagrant@vagrant:/devops-netology/terraform$ terraform workspace list
  default
* prod
  stage
```

Вывод `terraform plan` для prod 
```shell
vagrant@vagrant:/devops-netology/terraform$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.for-each["standard-v1"] will be created
  + resource "yandex_compute_instance" "for-each" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa ****** vagrant@vagrant
            EOT
        }
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80d7fnvf399b1c207j"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "yandex_vpc_subnet.my-subnet.id"
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.for-each["standard-v2"] will be created
  + resource "yandex_compute_instance" "for-each" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa ***** vagrant@vagrant
            EOT
        }
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v2"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80d7fnvf399b1c207j"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "yandex_vpc_subnet.my-subnet.id"
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.netology[0] will be created
  + resource "yandex_compute_instance" "netology" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa ***** vagrant@vagrant
            EOT
        }
      + name                      = "netology"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80d7fnvf399b1c207j"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.netology[1] will be created
  + resource "yandex_compute_instance" "netology" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa ***** vagrant@vagrant
            EOT
        }
      + name                      = "netology"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80d7fnvf399b1c207j"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.my-network will be created
  + resource "yandex_vpc_network" "my-network" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "my-network"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.my-subnet will be created
  + resource "yandex_vpc_subnet" "my-subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "my-subnet"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_for-each    = [
      + (known after apply),
      + (known after apply),
    ]
  + external_ip_address_netology_vm = [
      + (known after apply),
      + (known after apply),
    ]
  + internal_ip_address_for-each    = [
      + (known after apply),
      + (known after apply),
    ]
  + internal_ip_address_netology_vm = [
      + (known after apply),
      + (known after apply),
    ]

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── 

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

```
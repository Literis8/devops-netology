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

инициализируем terraform
```shell
vagrant@vagrant:~$ cd /devops-netology/src/terraform/
vagrant@vagrant:/devops-netology/src/terraform$ terraform init

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

Создаем бакет, дополняем переменные служебной записью и добавляем в main.tf
```terraform
resource "yandex_storage_bucket" "my-bucket" {
  access_key = "${var.SERVICE_KEY_ID}"
  secret_key = "${var.SERVICE_KEY_SECRET}"
  bucket = "tf-bucket"
}
```

Добавляем в provider.tf настройки бэкэнда и приводим его к следующему виду:
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
    bucket = yandex_storage_bucket.my-bucket.bucket
    region = "${var.YC_ZONE}"
    key = "devops-netology/terraform.tfstate"
    access_key = "${var.SERVICE_KEY_ID}"
    secret_key = "${var.SERVICE_KEY_SECRET}"
    
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

Запускаем терраформ на создание бэкэнда:
```terraform

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

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
* Вывод команды `terraform plan` для воркспейса `prod`.  

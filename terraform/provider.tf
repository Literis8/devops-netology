terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    key        = "bucket/terraform.tfstate"
    bucket     = "tf-bucket-yc"
    region     = "ru-central1-a"
    skip_region_validation      = true
    skip_credentials_validation = true

  }
}

provider "yandex" {
  token     = var.YC_TOKEN
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
  zone      = var.YC_ZONE
}
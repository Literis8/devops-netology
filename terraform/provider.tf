terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "my-bucket"
    region = var.YC_ZONE
    key = "devops-netology/terraform.tfstate"
    access_key = var.SERVICE_KEY_ID
    secret_key = var.SERVICE_KEY_SECRET

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
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
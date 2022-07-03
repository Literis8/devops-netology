resource "yandex_storage_bucket" "my-bucket" {
  access_key = "${var.SERVICE_KEY_ID}"
  secret_key = "${var.SERVICE_KEY_SECRET}"
  bucket = "my-bucket"
}

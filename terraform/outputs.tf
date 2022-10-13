output "internal_nginx_ip_address" {
  value = yandex_compute_instance.nginx.*.network_interface.0.ip_address
}

output "external_nginx_ip_address" {
  value = yandex_compute_instance.nginx.*.network_interface.0.nat_ip_address
}

output "internal_db01_ip_address" {
  value = yandex_compute_instance.db01.*.network_interface.0.ip_address
}

output "internal_db02_ip_address" {
  value = yandex_compute_instance.db02.*.network_interface.0.ip_address
}

output "internal_app_ip_address" {
  value = yandex_compute_instance.app.*.network_interface.0.ip_address
}

output "internal_gitlab_ip_address" {
  value = yandex_compute_instance.gitlab.*.network_interface.0.ip_address
}

output "internal_runner_ip_address" {
  value = yandex_compute_instance.runner.*.network_interface.0.ip_address
}

output "internal_monitoring_ip_address" {
  value = yandex_compute_instance.monitoring.*.network_interface.0.ip_address
}
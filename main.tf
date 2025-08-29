variable "folder_id" {
type = string
}

variable "cloud_id" {
type = string
}

variable "service_account_key_file" {
type = string
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}
provider "yandex" {
  zone = "ru-central1-a" # Зона доступности по умолчанию
  service_account_key_file = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}


resource "yandex_compute_disk" "boot-disk-vm1" {
  name     = "disk-web"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8vsghfu10ev5gdatkh"
}

resource "yandex_compute_disk" "boot-disk-vm2" {
  name     = "disk-web1"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "10"
  image_id = "fd8vsghfu10ev5gdatkh"
}

resource "yandex_compute_disk" "boot-disk-nat" {
  name     = "disk-nat"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8vsghfu10ev5gdatkh"
}

resource "yandex_compute_disk" "boot-disk-elastic" {
  name     = "disk-elastic"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8vsghfu10ev5gdatkh"
}

resource "yandex_compute_disk" "boot-disk-kibana" {
  name     = "disk-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8vsghfu10ev5gdatkh"
}

resource "yandex_compute_disk" "boot-disk-zabbix" {
  name     = "disk-zabbix"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8vsghfu10ev5gdatkh"
}


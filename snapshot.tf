resource "yandex_compute_snapshot_schedule" "shapshot-for-all" {
  name = "snap-shot-for-all"

  schedule_policy {
    expression = "0 0 * * * " # cron format
  }

  snapshot_count = 1 # number of images for each disk

  retention_period = "168h" # lifetime of a snapshot 

  disk_ids = ["${yandex_compute_disk.boot-disk-nat.id}", 
              "${yandex_compute_disk.boot-disk-vm2.id}",
              "${yandex_compute_disk.boot-disk-vm1.id}",
              "${yandex_compute_disk.boot-disk-elastic.id}",
              "${yandex_compute_disk.boot-disk-kibana.id}",
              "${yandex_compute_disk.boot-disk-zabbix.id}"]
}

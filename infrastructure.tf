#---------------NAT-VM------------

resource "yandex_compute_instance" "nat" {
  name                      = "nat"
  hostname                  = "nat"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    core_fraction = "20"
    memory = "2"
  }

  boot_disk {
    auto_delete = true
    disk_id = yandex_compute_disk.boot-disk-nat.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-public.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id, yandex_vpc_security_group.LAN-sg.id]
    nat = true
   }  

  scheduling_policy {
    preemptible = true   
   }

  metadata = {
   user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
      ssh_key_content         = file("~/.ssh/id_ed25519.pub")
    })
  }
}

#-----------------WEB1-VM-----------------


resource "yandex_compute_instance" "web1" {
  name                      = "web1"
  hostname                  = "web1"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    core_fraction = "20"
    memory = "2"
  }

  boot_disk {
    auto_delete = true
    disk_id = yandex_compute_disk.boot-disk-vm1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-for-web1.id
    security_group_ids = [yandex_vpc_security_group.web_sg.id, yandex_vpc_security_group.LAN-sg.id]
    nat = false
   }  

  scheduling_policy {
    preemptible = true
   }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
      ssh_key_content = file("/home/ilya-serv/.ssh/id_ed25519.pub")
    })
   }
}

#-----------WEB2-VM------------------

resource "yandex_compute_instance" "web2" {
  name                      = "web2"
  hostname                  = "web2"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-b"

  resources {
    cores  = "2"
    core_fraction = "20"
    memory = "2"
  }

  boot_disk {
    auto_delete = true
    disk_id = yandex_compute_disk.boot-disk-vm2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-for-web2.id
    security_group_ids = [yandex_vpc_security_group.web_sg.id, yandex_vpc_security_group.LAN-sg.id]
    nat = false
   }  

  scheduling_policy {
    preemptible = true
   }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
      ssh_key_content = file("/home/ilya-serv/.ssh/id_ed25519.pub")
    })
 }
}

#-------------ELATICSEARCH------------

resource "yandex_compute_instance" "elastic" {
  name                      = "elastic"
  hostname                  = "elasticsearch"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    core_fraction = "20"
    memory = "4"
  }

  boot_disk {
    auto_delete = true
    disk_id = yandex_compute_disk.boot-disk-elastic.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-private.id
    security_group_ids = [yandex_vpc_security_group.elastic_sg.id, yandex_vpc_security_group.LAN-sg.id]
    nat = false
   }  

  scheduling_policy {
    preemptible = true
   }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
      ssh_key_content = file("/home/ilya-serv/.ssh/id_ed25519.pub")
    })
 }
}

#-------------KIBANA-vm-------------

resource "yandex_compute_instance" "kibana" {
  name                      = "kibana"
  hostname                  = "kibana"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    core_fraction = "20"
    memory = "4"
  }

  boot_disk {
    auto_delete = true
    disk_id = yandex_compute_disk.boot-disk-kibana.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-public.id
    security_group_ids = [yandex_vpc_security_group.kibana_sg.id, yandex_vpc_security_group.LAN-sg.id]
    nat = true
   }  

  scheduling_policy {
    preemptible = true
   }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
      ssh_key_content = file("/home/ilya-serv/.ssh/id_ed25519.pub")
    })
 }
}

#-------------ZABBIX-vm------------


resource "yandex_compute_instance" "zabbix" {
  name                      = "zabbix"
  hostname                  = "zabbix"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    core_fraction = "20"
    memory = "4"
  }

  boot_disk {
    auto_delete = true
    disk_id = yandex_compute_disk.boot-disk-zabbix.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-public.id
    security_group_ids = [yandex_vpc_security_group.zabbix_sg.id, yandex_vpc_security_group.LAN-sg.id]
    nat = true
   }  

  scheduling_policy {
    preemptible = true
   }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tpl", {
      ssh_key_content = file("/home/ilya-serv/.ssh/id_ed25519.pub")
    })
  }
}


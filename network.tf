############################################
# Common settings network
############################################
resource "yandex_vpc_network" "network-one" {
  name = "network-for-web-and-elastic-and-zabbix-and-kibana"
}

resource "yandex_vpc_subnet" "subnet-for-web1" {
  name           = "subnet-for-web1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.123.0/28"]
  network_id     = yandex_vpc_network.network-one.id
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

resource "yandex_vpc_subnet" "subnet-for-web2" {
  name           = "subnet-for-web2"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.124.0/28"]
  network_id     = yandex_vpc_network.network-one.id
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}


resource "yandex_vpc_subnet" "subnet-private" {
  name           = "subnet-private"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.125.0/28"]
  network_id     = yandex_vpc_network.network-one.id
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

resource "yandex_vpc_subnet" "subnet-public" {
  name           = "subnet-public"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.126.0/28"]
  network_id     = yandex_vpc_network.network-one.id
}

########################################################
# Security Groups for NAT
########################################################

resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = "nat-instance-sg"
  network_id = yandex_vpc_network.network-one.id
  depends_on = [yandex_vpc_network.network-one]

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
    }
}


resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.network-one.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat.network_interface.0.ip_address
  }
}

##############################################
# Security Groups for LAN
##############################################

resource "yandex_vpc_security_group" "LAN-sg" {
  name       = "LAN-instanse-sg"
  network_id = yandex_vpc_network.network-one.id
  ingress {
    description    = "Allow 192.168.0.0/16"
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.0.0/16"]
    from_port      = 0
    to_port        = 65535
  }
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

}

##############################################
# Security Groups for WEB
##############################################

resource "yandex_vpc_security_group" "web_sg" {
  name       = "WEB-instanse-sg"
  network_id = yandex_vpc_network.network-one.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTP only from ALB"
    protocol       = "TCP"
    port           = 80
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }

   ingress {
    description    = "Allow Zabbix-agent"
    protocol       = "TCP"
    port           = 10050
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HC"
    protocol       = "TCP"
    port           = 80
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }

}

##################################################
# Security Groups for Elastic
###################################################
resource "yandex_vpc_security_group" "elastic_sg" {
  name       = "ELASTIC-instanse-sg"
  network_id = yandex_vpc_network.network-one.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow ELASTIC"
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "Allow HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

#################################################
# Security Groups for Kibana
#################################################

resource "yandex_vpc_security_group" "kibana_sg" {
  name       = "KIBANA-instanse-sg"
  network_id = yandex_vpc_network.network-one.id

  egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description    = "Allow Zabbix-server"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

##################################################
# Security Groups for Zabbix
##################################################
resource "yandex_vpc_security_group" "zabbix_sg" {
  name       = "ZABBIX-instanse-sg"
  network_id = yandex_vpc_network.network-one.id

  ingress {
    description    = "Allow Zabbix-server"
    protocol       = "TCP"
    port           = 10051
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow Zabbix-web "
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


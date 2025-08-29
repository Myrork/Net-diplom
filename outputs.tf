########################
# NAT
########################
output "nat_public_ip" {
  value = yandex_compute_instance.nat.network_interface.0.nat_ip_address
}

####################
# WEB
####################
output "web_fqdns" {
  value = [
    "web1.ilya-serv.internal",
    "web2.ilya-serv.internal"
  ]
}

output "web_private_map" {
  value = {
   "web1.ilya-serv.internal" = yandex_compute_instance.web1.network_interface.0.ip_address
   "web2.ilya-serv.internal" = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}

############################
# ZABBIX
############################
output "zabbix_private_ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
  }

output "zabbix_publick_ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
  }

output "zabbix_fqdn" {
  value = [
    "zabbix.ilya-serv.internal"
  ]
}

output "zabbix_private_map" {
  value = {
   "zabbix.ilya-serv.internal" = yandex_compute_instance.zabbix.network_interface.0.ip_address
  }
}

############################
# ELASTIC
############################

output "elastic_private_ip" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
  }

output "elastic_fqdn" {
  value = [
   "elasticsearch.ilya-serv.internal"
  ]
}

output "elastic_private_map" {
  value = {
   "elasticsearch.ilya-serv.internal" = yandex_compute_instance.elastic.network_interface.0.ip_address
  }
}

##########################
# KIBANA
##########################

output "kibana_private_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
  }

output "kibana_fqdn" {
  value = [
   "kibana.ilya-serv.internal"
  ]
}

output "kibana_private_map" {
  value = {
   "kibana.ilya-serv.internal" = yandex_compute_instance.kibana.network_interface.0.ip_address
  }
}


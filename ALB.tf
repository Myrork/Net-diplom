
#####################################
# Security Groups for ALB
#####################################

resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-sg"
  network_id = yandex_vpc_network.network-one.id

  ingress {
    description    = "HTTP from Internet"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ALB health check"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535 # Allow all ports
    # IP-address, which will receive requests for a health check
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    description    = "Any to backends"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#####################################
# Target group (ip and subnet backend host's)
#####################################
resource "yandex_alb_target_group" "tg-web" {
  name = "target-web"

  target {
    subnet_id  = yandex_vpc_subnet.subnet-for-web1.id
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
  }
  target {
    subnet_id  = yandex_vpc_subnet.subnet-for-web2.id
    ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}
######################################
# BACKEND GROUP (Port, healthchecks)
######################################

resource "yandex_alb_backend_group" "bg_web" {
  name = "backend-web"

  http_backend {
    name   = "http-80"
    port   = 80
    weight = 1 # both servers are equivalent

    target_group_ids = [yandex_alb_target_group.tg-web.id]

    healthcheck {
      timeout              = "1s"
      interval             = "2s"
      healthy_threshold    = 2
      unhealthy_threshold  = 2

      http_healthcheck {
        path = "/"


# Health check: ALB requests / from the server every 2 seconds.
# If the response takes 1 second and the code is 200, the server is considered alive.
# It takes 2 successful/unsuccessful checks in a row for the status to change.
  
     }
    }

    load_balancing_config {
      mode                   = "ROUND_ROBIN" # the requests take turns
      panic_threshold        = 50

# if less than 50% of the servers are alive, ALB will start sending traffic to all
# servers, even unhealthy ones (protection against the entire group failing).

      locality_aware_routing_percent = 0 
# If you set >0, some of the traffic will try to stay in the “nearest” locale/zone, and the rest will be distributed globally
    }
  }
}

########################################
# HTTP ROUTER + VIRTUAL HOST + ROUTE
########################################

resource "yandex_alb_http_router" "router" {
  name = "router-web"
}

resource "yandex_alb_virtual_host" "vh_default" {
  name           = "vh-default"
  http_router_id = yandex_alb_http_router.router.id

  # match all hostnames/paths and send to the backend group
  route {
    name = "web"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.bg_web.id
#ALB will select one of the healthy targets from this group and send a request there.
        timeout          = "3s"
      }
    }
  }
}

########################################
# ALB 
########################################

resource "yandex_alb_load_balancer" "alb" {
  name       = "alb-web"
  network_id = yandex_vpc_network.network-one.id
  security_group_ids = [yandex_vpc_security_group.alb_sg.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-public.id
    }
  }

  listener {
    name = "http"
    endpoint {
      address { 
        external_ipv4_address {} # Piblic IP
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}


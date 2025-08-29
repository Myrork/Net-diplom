#cloud-config
ssh_pwauth: no # by keys only
users: 
- name: ilya-serv 
  sudo: 'ALL=(ALL) NOPASSWD:ALL' 
  shell: /bin/bash 
  ssh_authorized_keys:
    - ${ssh_key_content}
runcmd:
  - sysctl -w net.ipv4.ip_forward=1 # allows packet routing between interfaces
  - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE # enables NAT-masking for outgoing traffic through the eth0 interface

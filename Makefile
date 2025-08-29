TF_DIR=.
ANSIBLE_DIR=./ansible-playbooks
USER=ilya-serv
NAT_HOST=nat
NAT_IP=$(shell terraform -chdir=$(TF_DIR) output -raw nat_public_ip)

# -------------------------------
# Terraform
# -------------------------------
validate:
	terraform -chdir=$(TF_DIR) validate

plan:
	terraform -chdir=$(TF_DIR) plan

apply:
	terraform -chdir=$(TF_DIR) apply -auto-approve

# -------------------------------
# Inventory
# -------------------------------
inventory:
	@echo "[web]" > $(ANSIBLE_DIR)/hosts.ini
	@terraform -chdir=$(TF_DIR) output -json web_fqdns | jq -r '.[]' | while read host; do \
		echo $$host ansible_user=$(USER) ansible_ssh_common_args=\"-o ProxyJump=$(USER)@$(NAT_IP) -o StrictHostKeyChecking=no\" >> $(ANSIBLE_DIR)/hosts.ini; \
	done
	
	@echo "[zabbix]" >> $(ANSIBLE_DIR)/hosts.ini
	@terraform -chdir=$(TF_DIR) output -json zabbix_fqdn | jq -r '.[]' | while read host; do \
		echo $$host ansible_user=$(USER) ansible_ssh_common_args=\"-o ProxyJump=$(USER)@$(NAT_IP) -o StrictHostKeyChecking=no\" >> $(ANSIBLE_DIR)/hosts.ini; \
	done
	@echo "[elastic]" >> $(ANSIBLE_DIR)/hosts.ini
	@terraform -chdir=$(TF_DIR) output -json elastic_fqdn | jq -r '.[]' | while read host; do \
                echo $$host ansible_user=$(USER) ansible_ssh_common_args=\"-o ProxyJump=$(USER)@$(NAT_IP) -o StrictHostKeyChecking=no\" >> $(ANSIBLE_DIR)/hosts.ini; \
	done
	@echo "[kibana]" >> $(ANSIBLE_DIR)/hosts.ini
	@terraform -chdir=$(TF_DIR) output -json kibana_fqdn | jq -r '.[]' | while read host; do \
                echo $$host ansible_user=$(USER) ansible_ssh_common_args=\"-o ProxyJump=$(USER)@$(NAT_IP) -o StrictHostKeyChecking=no\" >> $(ANSIBLE_DIR)/hosts.ini; \
	done

# -------------------------------
# Vars for Zabbix Agent
# -------------------------------
vars:
	@echo "zabbix_server_host: \"$(shell terraform -chdir=$(TF_DIR) output -raw zabbix_private_ip)\"" > $(ANSIBLE_DIR)/templates/vars-agent.yml
	@echo "zabbix_server_port: \"10051\"" >> $(ANSIBLE_DIR)/templates/vars-agent.yml
	@echo "check: \"check\"" >> $(ANSIBLE_DIR)/templates/vars-agent.yml

# -------------------------------
# Clearing known_hosts
# -------------------------------
ssh-clean:
	ssh-keygen -f ~/.ssh/known_hosts -R web1.ilya-serv.internal || true
	ssh-keygen -f ~/.ssh/known_hosts -R web2.ilya-serv.internal || true
	ssh-keygen -f ~/.ssh/known_hosts -R zabbix || true
	ssh-keygen -f ~/.ssh/known_hosts -R $(NAT_IP) || true
	ssh-keygen -f ~/.ssh/known_hosts -R elastic || true
	ssh-keygen -f ~/.ssh/known_hosts -R kibana || true


# -------------------------------
# Copying SSH key on NAT
# -------------------------------
copy-key:
	scp -o StrictHostKeyChecking=no /home/$(USER)/.ssh/id_ed25519 $(USER)@$(NAT_IP):/home/$(USER)/.ssh/

# -------------------------------
# Update /etc/hosts on NAT
# -------------------------------
update-hosts:
	@terraform -chdir=$(TF_DIR) output -json web_private_map | jq -r 'to_entries[] | "\(.value) \(.key)"' > /tmp/hosts-add
	@terraform -chdir=$(TF_DIR) output -json zabbix_private_map | jq -r 'to_entries[] | "\(.value) \(.key)"' >> /tmp/hosts-add
	@terraform -chdir=$(TF_DIR) output -json elastic_private_map | jq -r 'to_entries[] | "\(.value) \(.key)"' >> /tmp/hosts-add
	@terraform -chdir=$(TF_DIR) output -json kibana_private_map | jq -r 'to_entries[] | "\(.value) \(.key)"' >> /tmp/hosts-add
	@scp -o StrictHostKeyChecking=no /tmp/hosts-add $(USER)@$(NAT_IP):/tmp/hosts-add
	@ssh -o StrictHostKeyChecking=no $(USER)@$(NAT_IP) "sudo sh -c 'cat /tmp/hosts-add >> /etc/hosts'"

# -------------------------------
# Checking Ansible
# -------------------------------
ping:
	cd $(ANSIBLE_DIR) && ansible -i hosts.ini all -m ping

# -------------------------------
# start playbooks
# -------------------------------
deploy-nginx-docker:
	cd $(ANSIBLE_DIR) && ansible-playbook -i hosts.ini start-nginx.yml
	cd $(ANSIBLE_DIR) && ansible-playbook -i hosts.ini install-docker.yml

deploy-zabbix:
	cd $(ANSIBLE_DIR) && ansible-playbook -i hosts.ini zabbix-server.yml
	cd $(ANSIBLE_DIR) && ansible-playbook -i hosts.ini zabbix-agent.yml


deploy-elk:
	cd $(ANSIBLE_DIR) && ansible-playbook -i hosts.ini elastic.yml
	cd $(ANSIBLE_DIR) && ansible-playbook -i hosts.ini start-filebeat.yml
	cd $(ANSIBLE_DIR) && ansible-playbook -i hosts.ini kibana.yml
# -------------------------------
# full cycle
# -------------------------------
all: validate plan apply inventory vars ssh-clean copy-key update-hosts ping deploy-nginx-docker deploy-zabbix deploy-elk

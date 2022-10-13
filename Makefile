#
# General config
#

SHELL = /bin/bash

COLOR_RED = \033[0;31m
COLOR_GREEN = \033[0;32m
COLOR_ORANGE = \033[0;33m
COLOR_BLUE = \033[0;34m
COLOR_PURPLE = \033[0;35m
COLOR_TEAL = \033[0;36m
COLOR_WHITE = \033[0;37m
COLOR_RESET = \033[0m

# how many nodes we want for our inventory
NODE_COUNT = 5

.DEFAULT_GOAL := up
.PHONY: up down docker_compose_up docker_compose_down ssh_copy_id clean_inventory

up: docker_compose_up ssh_copy_id inventory
	@echo -e "\n${COLOR_GREEN}Now ready for Ansible!${COLOR_RESET}"
	@echo -e "\nTry: \n\$$ ansible nodes -m ping -i inventory${COLOR_RESET}"
	@echo -e "\nSee the ${COLOR_TEAL}inventory${COLOR_RESET} file for all available hosts."

down: docker_compose_down clean_inventory
	@echo -e "${COLOR_PURPLE}Inventory destroyed.${COLOR_RESET}"

docker_compose_up: PROMPT = [${COLOR_BLUE}Docker${COLOR_RESET}]
docker_compose_up:
	@echo -e "${PROMPT} ${COLOR_ORANGE}Bringing up inventory ${COLOR_RESET} ..."
	@tput sgr0
	@(docker-compose -p ansible-inventory up -d --build --scale node=${NODE_COUNT})
	@echo
	@tput sgr0

docker_compose_down: PROMPT = [${COLOR_BLUE}Docker${COLOR_RESET}]
docker_compose_down:
	@echo -e "${PROMPT} ${COLOR_ORANGE}Bringing down inventory ${COLOR_RESET} ..."
	@tput sgr0
	@(docker-compose -p ansible-inventory down)
	@echo
	@tput sgr0
    
ssh_copy_id: PROMPT = [${COLOR_BLUE}SSH${COLOR_RESET}]
ssh_copy_id:
	@echo -e "${PROMPT} ${COLOR_ORANGE}Copying SSH public key to all node(s) ${COLOR_RESET} ..."
	@tput sgr0
	@$(call docker_inventory_ports) | xargs -I {} sshpass -p root ssh-copy-id -o "StrictHostKeyChecking=no" -p {} root@localhost
	@echo
	@tput sgr0

inventory: PROMPT = [${COLOR_BLUE}Ansible${COLOR_RESET}]
inventory:
	@echo -e "${PROMPT} ${COLOR_ORANGE}Generating ${COLOR_TEAL}inventory ${COLOR_ORANGE}file ${COLOR_RESET} ..."
	@tput sgr0
	@echo "[nodes]" > inventory
	@$(call docker_inventory_ports) | awk 'BEGIN{OFS="";} {print "node_", NR, " ansible_port=", $$1, " ansible_host=localhost ansible_user=root";}' >> inventory
	@cat inventory
	@tput sgr0

clean_inventory:
	@-rm inventory

# query our docker containers for their exposed local SSH port (mapping to their internal port 22)
define docker_inventory_ports
	# get all containers in our inventory                       | grab the container ID              | get the port mappings                | extract the TCP ports                    | filter out any other port mappings (only care about TCP ports)
	docker container ls --filter 'name=ansible-inventory-node*' --format='{{json .ID}}' |  xargs -I {} docker container port {} | awk '{gsub(/22\/tcp -> 0.0.0.0:/,"");}1' | grep -v -E '[^0-9]'
endef

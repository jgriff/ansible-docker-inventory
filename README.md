# Ansible Docker Inventory

Provides a quick and easy way to play with Ansible on an inventory provided by Docker.  

## Quick Start

Bring up the inventory (spin up some Docker containers):
```
make up
```

This will:

1.  Spin up 5 Ubuntu containers (see the [`Dockerfile`](Dockerfile) for image details).
2.  Add your public SSH key to each of the host containers (Ansible works over SSH).  
3.  Generate an `inventory` file for Ansible that lists all of the Docker hosts.

You're now ready to run some ansible commands against your new inventory:
```
ansible nodes -m ping -i inventory
```

## Burn It

When you're done, burn the containers:
```
make down
```
This destroys the Docker containers and the `inventory` file, returning you to an original clean state.

You can `make up` and `make down` to quickly test your playbooks against clean inventories.



## Requirements

* `Make` - For management of the inventory (`up` and `down`).
* `docker-compose` - To run the inventory containers.
* [`sshpass`](https://linux.die.net/man/1/sshpass) - For no prompt `ssh-copy-id` to copy your public key to the hosts.  See [this gist](https://gist.github.com/arunoda/7790979#installing-sshpass) for installation instructions (if using Homebrew, see [here](https://stackoverflow.com/a/62623099)).
* No direct Windows support.


## The `inventory` File

When you
```
make up
```
an `inventory` file is generated listing all of the newly created Docker hosts.

You can include this file in your Ansible playbooks in any way you want.  One simple method is to pass it on the command line using the `-i` option:
```
ansible ... -i inventory
```

It looks like
```
[nodes]
node_1 ansible_port=32842 ansible_host=localhost ansible_user=root
node_2 ansible_port=32840 ansible_host=localhost ansible_user=root
node_3 ansible_port=32839 ansible_host=localhost ansible_user=root
node_4 ansible_port=32843 ansible_host=localhost ansible_user=root
node_5 ansible_port=32841 ansible_host=localhost ansible_user=root
```

➤ _Note that the `ansible_port` is dynamically selected by Docker, and maps to the container's private ssh port `22`._

## Changing the Host Count
You can easily change the number of hosts that get created by editing the `NODE_COUNT` variable in the [`Makefile`](Makefile).  The default is 5.

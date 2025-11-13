#!/bin/bash
set -e

echo "[+] Running full Proxmox hardening pipeline..."
ansible-playbook -i inventories/prod.ini playbooks/pipeline.yml --ask-pass

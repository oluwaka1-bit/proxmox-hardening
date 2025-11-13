# Proxmox VE 9 / Debian 13 Hardening Framework

A complete automation framework for hardening Proxmox VE 9 (Debian 13) using SCAP, OpenSCAP, and Ansible.

This project provides a fully automated pipeline that:

- Builds STIG/SCAP (Debian 13) compliance content on an Ubuntu SCAP Builder VM
- Syncs the SCAP datastream to one or more Proxmox nodes
- Performs pre-remediation SCAP scans with OpenSCAP
- Applies safe, Proxmox-aware hardening remediations (no cluster-breaking changes)
- Re-runs SCAP scans to validate improved compliance
- Stores machine-readable and HTML reports (`stig-before.html` / `stig-after.html`) on each node

## Architecture

- **SCAP Builder / Ansible Controller**: Ubuntu VM running in Proxmox.
- **Targets**: Proxmox VE 9 nodes (Debian 13 base).

Ansible runs on the Ubuntu VM and connects to Proxmox nodes over SSH.

## Quick Start

On the Ubuntu SCAP Builder:

```bash
git clone https://github.com/<your-username>/proxmox-hardening.git
cd proxmox-hardening

# Edit inventory to point at your PVE node(s)
nano inventories/prod.ini

# Run full pipeline: build SCAP -> sync -> scan -> remediate -> rescan
./scripts/run_pipeline.sh


---

## 🧩 Using RHEL 8 as the SCAP Builder / Ansible Controller

This project was originally tested with an Ubuntu “SCAP Builder” VM, but it works just as well with a **RHEL 8** VM as the controller. In both cases:

- The builder VM runs Ansible and holds the SCAP datastream.
- The Proxmox node(s) run OpenSCAP locally and generate the actual reports.

### 1. Prepare the RHEL 8 Builder VM

```bash
sudo dnf install -y git ansible openscap-scanner sshpass



2. Place the Debian 13 SCAP Datastream on RHEL 8
sudo mkdir -p /opt/stig
sudo scp root@<PVE-IP>:/opt/stig/ssg-debian13-ds.xml /opt/stig/



3. Update Inventory for RHEL 8 Builder
[scap_builder]
localhost ansible_connection=local

[pve]
192.168.1.228 ansible_user=root

SSH key variant:
ansible_ssh_private_key_file=~/.ssh/id_ed25519


4. Ensure Proxmox Has OpenSCAP Installed

apt update
apt install -y openscap-scanner

If Python is missing:

[pve:vars]
ansible_python_interpreter=/usr/bin/python3


5. Create or Verify the Remediation Script on Proxmox

mkdir -p /opt/stig

cat <<'EOR' > /opt/stig/stig-remediate-pve.sh

#!/bin/bash
echo "[+] Running Proxmox VE STIG remediation (placeholder)"
exit 0
EOR
chmod +x /opt/stig/stig-remediate-pve.sh


Override path (optional):

pve_stig_remediation_script=/path/to/script.sh


6. Run Pipeline from RHEL 8 Builder

cd proxmox-hardening
./scripts/run_pipeline.sh


Reports appear at:
/var/log/scap/
  ├── stig-before.html
  └── stig-after.html

7. Ubuntu vs RHEL Comparison

Feature	Ubuntu Builder	RHEL 8 Builder

Package manager	apt	dnf

Install cmd	apt install ansible openscap-utils	dnf install ansible openscap-scanner

SCAP DS path	/opt/stig/ssg-debian13-ds.xml	same

Inventory	localhost ansible_connection=local	same

Targets	Proxmox VE 9	Proxmox VE 9



---

# 📌 **SECTION 2 — What that command does**

The above command:

- Finds your `README.md`
- **Appends** the entire RHEL 8 documentation block to the bottom
- Does NOT overwrite anything already in the file

So after running it, your README will now end with the RHEL 8 support section.

---



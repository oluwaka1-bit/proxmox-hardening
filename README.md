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


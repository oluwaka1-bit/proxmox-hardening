# Proxmox Hardening Pipeline — Architecture Diagram

Below is a high-level architecture diagram showing how the SCAP builder and Proxmox nodes interact throughout the hardening pipeline.


+----------------------------------------------------------+
| Ubuntu SCAP Builder VM |
| |
| - Hosts SCAP Datastream (ssg-debian13-ds.xml) |
| - Runs Ansible Playbooks |
| - Controls SCAP Before/After Scans |
| - Executes Pipeline: |
| scap_build → scap_scan(before) → pve_stig |
| → scap_scan(after) |
| |
+-------------+---------------------------+-----------------+
| SSH (root) |
v v
+---------------------------+ +---------------------------+
| Proxmox Node #1 | | Proxmox Node #2 |
| (e.g., 192.168.1.228) | | (Optional) |
| | | |
| - Receives SCAP Data | | - Receives SCAP Data |
| - Runs SCAP Scans | | - Runs SCAP Scans |
| - Runs Remediation | | - Runs Remediation |
| - Produces Reports | | - Produces Reports |
| /var/log/scap/ | | /var/log/scap/ |
+---------------------------+ +---------------------------+

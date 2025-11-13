# Proxmox Hardening Pipeline — Troubleshooting & Lab Recreation Guide

This document explains:

- How to recreate the entire SCAP → remediation → rescan pipeline in a fresh environment  
- Which files must be edited and how  
- All errors encountered during development  
- Their exact causes and fixes  
- Tips for adapting the pipeline to new Proxmox nodes and new lab setups  

This is intended as a companion to the main README.

---

# 1. Rebuilding the Full Lab in a New Environment

To recreate the hardening system, you must set up the following:

---

## Ubuntu SCAP Builder VM (Controller)

### Install dependencies:

\`\`\`bash
apt update
apt install -y git ansible sshpass openscap-utils
\`\`\`

### Clone the repository:

\`\`\`bash
git clone https://github.com/<your-username>/proxmox-hardening.git
cd proxmox-hardening
\`\`\`

### Ensure SCAP datastream exists:

Must be at:

\`\`\`
/opt/stig/ssg-debian13-ds.xml
\`\`\`

If the file exists on the Proxmox node, copy it:

\`\`\`bash
mkdir -p /opt/stig
scp root@<PVE-IP>:/opt/stig/ssg-debian13-ds.xml /opt/stig/
\`\`\`

---

## Proxmox Node (Target)

Must have:

\`\`\`
/opt/stig/ssg-debian13-ds.xml
/opt/stig/stig-remediate-pve.sh
\`\`\`

Create directory if missing:

\`\`\`bash
mkdir -p /opt/stig
\`\`\`

Create placeholder remediation script if needed:

\`\`\`bash
cat <<'EOR' > /opt/stig/stig-remediate-pve.sh
#!/bin/bash
echo "[+] Running Proxmox STIG remediation (placeholder)"
exit 0
EOR

chmod +x /opt/stig/stig-remediate-pve.sh
\`\`\`

---

# 2. Files That MUST Be Edited in Any New Lab

These are the only files you need to customize when recreating the pipeline.

---

## inventories/prod.ini

Defines which nodes to scan + how to authenticate.

### Example with password prompt:

\`\`\`ini
[scap_builder]
localhost ansible_connection=local

[pve]
192.168.1.228 ansible_user=root
\`\`\`

### Multiple PVE nodes:

\`\`\`ini
[pve]
192.168.1.228 ansible_user=root
192.168.1.229 ansible_user=root
192.168.1.230 ansible_user=root
\`\`\`

### SSH key:

\`\`\`ini
ansible_ssh_private_key_file=~/.ssh/id_ed25519
\`\`\`

### Stored password (lab only):

\`\`\`ini
ansible_ssh_pass=PASSWORD
\`\`\`

---

## scripts/run_pipeline.sh

Should contain:

\`\`\`bash
ansible-playbook -i inventories/prod.ini playbooks/pipeline.yml --ask-pass
\`\`\`

---

## playbooks/pipeline.yml

Modify SCAP datastream path:

\`\`\`yaml
scap_ds_path: "/opt/stig/ssg-debian13-ds.xml"
\`\`\`

Modify remediation script path:

\`\`\`yaml
pve_stig_remediation_script: "/opt/stig/stig-remediate-pve.sh"
\`\`\`

---

## SCAP Datastream

Must exist on BOTH:

- Ubuntu controller → \`/opt/stig/ssg-debian13-ds.xml\`
- Proxmox nodes → \`/opt/stig/ssg-debian13-ds.xml\`

---

# 3. Common Issues Encountered (and Fixes)

These are all REAL issues hit during setup.

---

## Error 1: Heredoc never closed (cat <<EOF)

### Symptom:
\`\`\`
>
>
>
\`\`\`

### Fix:
Press Ctrl+C  
Rewrite block ending with:

\`\`\`
EOF
\`\`\`

---

## Error 2: “role 'scap_build' was not found”

### Cause:
Role directories not created.

### Fix:
\`\`\`bash
mkdir -p playbooks/roles/scap_build/tasks
touch playbooks/roles/scap_build/tasks/main.yml
\`\`\`

Repeat for:

- scap_scan  
- pve_stig  

---

## Error 3: SCAP scan fails with rc=2

### Cause:
OpenSCAP uses rc=2 for “rules failed” (normal).  
Ansible considered it an error.

### Fix:

\`\`\`yaml
failed_when: scap_scan_result.rc not in [0, 2]
\`\`\`

---

## Error 4: Missing remediation script

\`\`\`
PVE STIG remediation script not found
\`\`\`

### Fix:
Create:

\`\`\`bash
mkdir -p /opt/stig
nano /opt/stig/stig-remediate-pve.sh
chmod +x /opt/stig/stig-remediate-pve.sh
\`\`\`

Or override the path in inventory.

---

## Error 5: SSH auth failure

\`\`\`
Permission denied (publickey,password)
\`\`\`

### Fix:
Use password prompting:

- Remove ansible_ssh_pass from inventory  
- Use \`--ask-pass\`  

Or install SSH key:

\`\`\`bash
ssh-copy-id root@<PVE-IP>
\`\`\`

---

## Error 6: Missing remote OVAL definitions

OpenSCAP warning:

\`\`\`
Use --fetch-remote-resources
\`\`\`

### Fix:
Add this flag in scap_scan role.

---

# 4. Verifying Successful Pipeline Execution

On Proxmox:

\`\`\`bash
ls -l /var/log/scap/
\`\`\`

You should see:

- stig-before.html  
- stig-before.arf.xml  
- stig-after.html  
- stig-after.arf.xml  

---

# 5. Expanding to Multiple Proxmox Nodes

Add nodes:

\`\`\`ini
[pve]
192.168.1.228 ansible_user=root
192.168.1.229 ansible_user=root
\`\`\`

Pipeline will automatically:

- SCAN all nodes  
- REMEDIATE all nodes  
- RESCAN all nodes  

---

# 6. Notes for Reuse in Other Labs

- Only 3 files need editing: prod.ini, pipeline.yml, remediation script  
- SCAP datastream must be on both controller + nodes  
- Must update IPs when cloning into new environments  
- Remediation script must always exist  
- SSH must work before Ansible can run  

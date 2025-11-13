# Proxmox SCAP Hardening Pipeline — Flowchart


            ┌────────────────────────┐
            │   Start Pipeline       │
            └────────────┬──────────┘
                         │
                         ▼
          ┌─────────────────────────────┐
          │  scap_build (on builder)    │
          │  - Verify SCAP DS exists    │
          └────────────┬────────────────┘
                         │
                         ▼
         ┌──────────────────────────────┐
         │  scap_scan (before scan)     │
         │  - Run OpenSCAP XCCDF eval   │
         │  - Save stig-before.html     │
         └────────────┬─────────────────┘
                         │
                         ▼
         ┌──────────────────────────────┐
         │   pve_stig remediation       │
         │   - Run remediation script   │
         │   - Make safe Proxmox edits  │
         └────────────┬─────────────────┘
                         │
                         ▼
         ┌──────────────────────────────┐
         │   scap_scan (after scan)     │
         │   - Run OpenSCAP again       │
         │   - Save stig-after.html     │
         └────────────┬─────────────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │   Pipeline Complete    │
            │   Reports Generated    │
            └────────────────────────┘


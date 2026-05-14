# Lab Setup Guide

## Prerequisites

Before starting, ensure your host machine has:
- **RAM:** 16GB minimum (8GB works but will be slow with 3 VMs running)
- **Storage:** 100GB free disk space
- **CPU:** Virtualization enabled in BIOS (Intel VT-x or AMD-V)
- **OS:** Windows, macOS, or Linux host — all work fine

## Phase 1: VirtualBox Setup

1. Download VirtualBox from virtualbox.org (free)
2. Download the VirtualBox Extension Pack (same page) — needed for USB support
3. Install both

**Concept check before continuing:** Understand what a snapshot is. In VirtualBox, a snapshot freezes the entire state of a VM at a point in time. If you run malware in your lab and want to clean up, you revert to a snapshot instead of reinstalling. Always take a snapshot of a clean, working VM before experimenting.

## Phase 2: VM Creation Order

Create VMs in this order. Each has a role:

### VM 1: Ubuntu Server (Wazuh SIEM)
- **ISO:** Ubuntu Server 22.04 LTS
- **RAM:** 4GB | **CPU:** 2 cores | **Storage:** 50GB
- **Network:** Host-only Adapter (isolated lab network)
- This machine will run Wazuh Manager and the Kibana web interface

### VM 2: Windows 10 (Monitored Endpoint)
- **ISO:** Windows 10 (use the Media Creation Tool from Microsoft)
- **RAM:** 4GB | **CPU:** 2 cores | **Storage:** 60GB
- **Network:** Host-only Adapter (same network as SIEM)
- This machine will have Sysmon and the Wazuh Agent installed

### VM 3: Kali Linux (Attack Simulation)
- **ISO:** Kali Linux from kali.org
- **RAM:** 2GB | **CPU:** 2 cores | **Storage:** 30GB
- **Network:** Host-only Adapter
- Only used for controlled attack simulation. Never connect to the internet from this VM.

## Phase 3: Network Configuration

All VMs should be on the same Host-Only network so they can communicate with each other but NOT with the internet. In VirtualBox:

Settings > Network > Adapter 1 > Host-only Adapter

Assign static IPs (in each VM's network settings):
- Wazuh SIEM: 192.168.56.10
- Windows endpoint: 192.168.56.20
- Kali attacker: 192.168.56.30

## Phase 4: Wazuh Installation

Follow the official Wazuh quickstart: https://documentation.wazuh.com/current/quickstart.html

Install on your Ubuntu Server VM. The quickstart installs everything (Manager, Indexer, Dashboard) in one command. This takes 15-20 minutes.

Once installed, access the dashboard at: https://192.168.56.10 (from your host browser)

## Phase 5: Connect Windows Endpoint

1. Run `install_sysmon.ps1` on the Windows VM (as Administrator)
2. Run `deploy_wazuh_agent.sh` script or manually install the Wazuh Windows Agent
3. Verify events appear in the Wazuh dashboard

## Verification Checklist

- [ ] All 3 VMs boot successfully
- [ ] VMs can ping each other but not the internet
- [ ] Wazuh dashboard accessible from host browser
- [ ] Windows VM shows as connected agent in Wazuh
- [ ] Sysmon Event ID 1 events visible in Wazuh
- [ ] Clean snapshots taken of all 3 VMs

# 🛡️ SOC Home Lab — Threat Detection & Incident Response Simulation

**Author:** Mordie Lawrence | Voorhees University | Rising Sophomore  
**Focus:** Security Operations, SIEM Engineering, Threat Detection, Incident Response  
**Status:** 🟢 Active Development

---

## Overview

This project simulates an enterprise Security Operations Center (SOC) environment built entirely on a personal machine using open-source tools. It demonstrates real analyst workflows: log ingestion, SIEM rule development, attack simulation, alert triage, and professional incident documentation.

This is not a tutorial follow-along. Every detection rule, script, and report was written from scratch with a deliberate understanding of the underlying attack technique and the log artifacts it produces.

---

## Lab Architecture

```
┌─────────────────────────────────────────────────────┐
│                  VirtualBox Host                    │
│                                                     │
│  ┌─────────────┐    ┌─────────────────────────┐    │
│  │  Kali Linux │    │      pfSense Firewall    │    │
│  │  (Attacker) │───▶│   Network Segmentation  │    │
│  └─────────────┘    └────────────┬────────────┘    │
│                                  │                  │
│              ┌───────────────────┼──────────┐       │
│              │                   │          │       │
│   ┌──────────▼──┐    ┌──────────▼──┐       │       │
│   │  Windows 10  │    │ Ubuntu SIEM │       │       │
│   │  + Sysmon    │    │  (Wazuh)    │       │       │
│   │  + Wazuh Agt │───▶│  + Kibana   │       │       │
│   └─────────────┘    └─────────────┘       │       │
└─────────────────────────────────────────────────────┘
```

**Components:**
| VM | OS | Role | Tools |
|---|---|---|---|
| SIEM Server | Ubuntu 22.04 LTS | Log collection, correlation, alerting | Wazuh Manager, Kibana |
| Windows Endpoint | Windows 10 | Monitored workstation | Wazuh Agent, Sysmon |
| Attacker | Kali Linux | Controlled attack simulation | Atomic Red Team, nmap, Metasploit |
| Firewall | pfSense | Network visibility, traffic logging | pfSense + Wazuh log integration |

---

## Detection Rules

Custom detection rules mapped to the [MITRE ATT&CK Framework](https://attack.mitre.org/).

| Rule | Technique ID | Tactic | Severity |
|---|---|---|---|
| PowerShell Base64 Encoded Command | T1059.001 | Execution | High |
| New Local Admin Account Created | T1136.001 | Persistence | High |
| LSASS Memory Access Attempt | T1003.001 | Credential Access | Critical |
| Port Scan Detected from Internal Host | T1046 | Discovery | Medium |
| Suspicious Scheduled Task Creation | T1053.005 | Persistence | High |
| Outbound Connection to Known Malicious IP | T1071 | Command & Control | Critical |

---

## Incident Reports

Professional incident reports written for simulated security events detected in the lab.

| Report | Severity | MITRE Technique | Date |
|---|---|---|---|
| [IR-001 — PowerShell Execution Chain](./incident-reports/completed/IR-001-powershell-execution.md) | High | T1059.001 | — |
| [IR-002 — Credential Dumping Attempt](./incident-reports/completed/IR-002-credential-dump.md) | Critical | T1003.001 | — |

---

## Scripts

| Script | Language | Purpose |
|---|---|---|
| `log-parser/parse_sysmon.py` | Python | Parses Sysmon XML logs into structured JSON |
| `alert-automation/ioc_extractor.py` | Python | Extracts IOCs from Wazuh alerts |
| `setup/install_sysmon.ps1` | PowerShell | Automates Sysmon deployment with config |
| `setup/deploy_wazuh_agent.sh` | Bash | Wazuh agent install and enrollment |

---

## Skills Demonstrated

- **SIEM Operations** — Wazuh deployment, log ingestion, dashboard configuration
- **Detection Engineering** — Custom rule authoring, MITRE ATT&CK mapping, false positive tuning
- **Log Analysis** — Windows Event Log forensics, Sysmon telemetry, network flow analysis
- **Threat Simulation** — Controlled execution of ATT&CK techniques using Atomic Red Team
- **Incident Response** — Timeline reconstruction, evidence collection, professional IR reporting
- **Scripting & Automation** — Python and Bash for analyst workflow automation
- **Network Security** — Firewall logging, traffic analysis, port scan detection

---

## Tools & Technologies

`Wazuh` `Kibana` `Sysmon` `VirtualBox` `Kali Linux` `pfSense` `Atomic Red Team` `Python` `Bash` `PowerShell` `MITRE ATT&CK` `Sigma Rules`

---

## Project Roadmap

- [x] Lab architecture designed
- [ ] VirtualBox environment deployed
- [ ] Wazuh SIEM operational
- [ ] Sysmon installed and logging
- [ ] First attack simulation executed
- [ ] First custom detection rule written
- [ ] pfSense network visibility integrated
- [ ] First incident report completed
- [ ] Sigma rules authored
- [ ] Dashboard screenshots documented

---

## Documentation

- [Lab Setup Guide](./docs/lab-setup-guide.md)
- [Detection Rule Writing Guide](./docs/detection-rule-guide.md)
- [Incident Response Process](./docs/ir-process.md)
- [Lab Architecture Details](./lab-architecture/)

---

> ⚠️ **Ethics Notice:** All attack simulations are performed exclusively in an isolated, offline lab environment against systems I own and operate. No techniques are used against any external system. This project is for educational and professional development purposes only.

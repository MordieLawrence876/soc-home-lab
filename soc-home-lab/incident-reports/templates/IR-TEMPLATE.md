# Incident Report — [IR-XXX]: [Incident Title]

**Report ID:** IR-XXX  
**Classification:** CONFIDENTIAL — LAB ENVIRONMENT  
**Severity:** [ ] Critical  [ ] High  [ ] Medium  [ ] Low  
**Status:** [ ] Open  [ ] Contained  [ ] Resolved  
**Analyst:** Mordie Lawrence  
**Date Detected:** YYYY-MM-DD HH:MM UTC  
**Date Resolved:** YYYY-MM-DD HH:MM UTC  

---

## 1. Executive Summary

*(2–3 sentences. Write this for a non-technical manager. What happened, how bad was it, and is it resolved? No jargon.)*

---

## 2. Incident Timeline

| Timestamp (UTC) | Event | Source | Evidence |
|---|---|---|---|
| YYYY-MM-DD HH:MM | [What happened] | [Log source] | [Event ID / log excerpt] |
| YYYY-MM-DD HH:MM | [Alert fired in SIEM] | Wazuh | Rule ID XXXX |
| YYYY-MM-DD HH:MM | [Analyst began investigation] | — | — |

---

## 3. Technical Findings

### 3.1 Initial Detection

Describe what triggered the alert. Which SIEM rule fired? What log source? Include the raw log entry.

```
[Paste raw log entry here]
```

**Rule that fired:** [Rule name]  
**MITRE ATT&CK Technique:** [T-XXXX.XXX — Technique Name]  
**MITRE Tactic:** [Tactic Name]

### 3.2 Investigation Steps

**Step 1:** [What you checked and why]  
**Finding:** [What you found]

**Step 2:** [What you checked and why]  
**Finding:** [What you found]

### 3.3 Indicators of Compromise (IOCs)

| Type | Value | Context |
|---|---|---|
| Process name | [e.g., powershell.exe] | Used to execute encoded command |
| Command line | [e.g., -enc AAAAAA...] | Base64 encoded payload |
| Event ID | [e.g., 4688] | Process creation logged |

### 3.4 Affected Systems

| Hostname | IP Address | Role | Impact |
|---|---|---|---|
| [Hostname] | [IP] | [Workstation/Server] | [What was affected] |

---

## 4. Root Cause Analysis

*(What allowed this to happen?)*

---

## 5. Containment Actions Taken

- [ ] Isolated affected VM from lab network
- [ ] Terminated malicious process
- [ ] Reverted to clean snapshot
- [ ] Preserved logs and artifacts for analysis

---

## 6. Remediation & Recovery

*(How was the system restored to a known good state?)*

---

## 7. Lessons Learned & Recommendations

| Recommendation | Priority | Rationale |
|---|---|---|
| [e.g., Restrict PowerShell execution policy] | High | Prevents unsigned script execution |
| [e.g., Enable script block logging] | High | Captures full PowerShell commands |

---

## 8. Detection Rule Outcome

- **Rule that detected this:** [Rule name]
- **True positive?** Yes / No
- **Rule improvements made:** [Any tuning done]

---

## 9. References

- [MITRE ATT&CK T-XXXX](https://attack.mitre.org/techniques/TXXXX/)
- [Atomic Red Team Test](https://github.com/redcanaryco/atomic-red-team)

---
*Report completed by: Mordie Lawrence | 2026-05-13*

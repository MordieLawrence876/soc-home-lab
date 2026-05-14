#!/usr/bin/env python3
"""
parse_sysmon.py — Sysmon XML Log Parser
========================================
Author: Mordie Lawrence
Project: SOC Home Lab

PURPOSE:
    Parses raw Sysmon event log exports (XML format) into structured JSON
    for easier analysis, ingestion, and scripting. This mirrors what a SIEM
    does internally — normalize diverse log formats into a consistent schema.

WHAT YOU LEARN BY BUILDING THIS:
    - The structure of Sysmon events and what each field means
    - Why log normalization matters in a SOC environment
    - Python XML parsing and JSON output
    - How to extract analyst-relevant fields from noisy raw logs

USAGE:
    python3 parse_sysmon.py --input sysmon_export.xml --output parsed_events.json
    python3 parse_sysmon.py --input sysmon_export.xml --event-id 1
    python3 parse_sysmon.py --input sysmon_export.xml --event-id 3 --output network.json

SYSMON EVENT IDS REFERENCE:
    1  = Process Create
    2  = File Creation Time Changed
    3  = Network Connection
    5  = Process Terminated
    7  = Image Loaded (DLL)
    8  = CreateRemoteThread (often malicious)
    10 = ProcessAccess (LSASS dumping shows here)
    11 = FileCreate
    13 = Registry Value Set
    22 = DNS Query

BEFORE RUNNING:
    Export Sysmon logs from Windows Event Viewer:
    Event Viewer > Applications and Services Logs > Microsoft > Windows > Sysmon > Operational
    Right-click > Save All Events As > XML format
"""

import xml.etree.ElementTree as ET
import json
import argparse
import sys
from datetime import datetime


# Sysmon XML namespace — all Sysmon events use this
SYSMON_NS = "http://schemas.microsoft.com/win/2004/08/events/event"


def parse_event(event_element):
    """
    Parse a single Sysmon <Event> XML element into a Python dictionary.

    Sysmon events have two main sections:
      - System: metadata (EventID, timestamp, computer name)
      - EventData: the actual security-relevant fields (process name, PID, etc.)
    """
    parsed = {}

    # --- Parse System section (metadata) ---
    system = event_element.find(f"{{{SYSMON_NS}}}System")
    if system is not None:
        event_id_el = system.find(f"{{{SYSMON_NS}}}EventID")
        time_created_el = system.find(f"{{{SYSMON_NS}}}TimeCreated")
        computer_el = system.find(f"{{{SYSMON_NS}}}Computer")

        parsed["event_id"] = int(event_id_el.text) if event_id_el is not None else None
        parsed["timestamp"] = time_created_el.get("SystemTime") if time_created_el is not None else None
        parsed["computer"] = computer_el.text if computer_el is not None else None

    # --- Parse EventData section (security fields) ---
    event_data = event_element.find(f"{{{SYSMON_NS}}}EventData")
    if event_data is not None:
        for data_field in event_data.findall(f"{{{SYSMON_NS}}}Data"):
            field_name = data_field.get("Name", "unknown")
            field_value = data_field.text or ""
            parsed[field_name] = field_value

    # --- Add human-readable event type label ---
    event_type_map = {
        1: "ProcessCreate",
        2: "FileCreationTimeChanged",
        3: "NetworkConnection",
        5: "ProcessTerminated",
        7: "ImageLoaded",
        8: "CreateRemoteThread",
        10: "ProcessAccess",
        11: "FileCreate",
        13: "RegistryValueSet",
        22: "DNSQuery",
    }
    parsed["event_type"] = event_type_map.get(parsed.get("event_id"), "Unknown")

    return parsed


def flag_suspicious(event):
    """
    Basic heuristic flagging — not a replacement for SIEM rules, but a
    useful first-pass filter for obvious suspicious patterns.

    LEARNING NOTE: These are simple keyword checks. Real detection logic
    uses behavioral baselining, frequency analysis, and ML — but string
    matching on known-bad patterns is still valid and widely used.
    """
    flags = []
    cmd = event.get("CommandLine", "").lower()
    image = event.get("Image", "").lower()
    parent = event.get("ParentImage", "").lower()

    # PowerShell encoded commands
    if "-enc" in cmd or "-encodedcommand" in cmd:
        flags.append("SUSPICIOUS: PowerShell encoded command (T1059.001)")

    # LSASS access — credential dumping indicator
    if "lsass" in event.get("TargetImage", "").lower():
        flags.append("CRITICAL: LSASS memory access detected (T1003.001)")

    # Unusual PowerShell parent (Office, browser spawning PS is malicious)
    suspicious_parents = ["winword.exe", "excel.exe", "outlook.exe", "chrome.exe", "firefox.exe"]
    if "powershell.exe" in image and any(p in parent for p in suspicious_parents):
        flags.append(f"HIGH: PowerShell spawned from suspicious parent: {parent}")

    # Network connection from scripting engines
    if event.get("event_id") == 3:  # NetworkConnection
        if any(x in image for x in ["powershell", "wscript", "cscript", "mshta"]):
            flags.append("SUSPICIOUS: Script engine making network connection (possible C2)")

    if flags:
        event["analyst_flags"] = flags
        event["requires_review"] = True
    else:
        event["requires_review"] = False

    return event


def main():
    parser = argparse.ArgumentParser(
        description="Parse Sysmon XML exports into structured JSON for analysis"
    )
    parser.add_argument("--input", required=True, help="Path to Sysmon XML export file")
    parser.add_argument("--output", default=None, help="Output JSON file (default: print to stdout)")
    parser.add_argument("--event-id", type=int, default=None, help="Filter by specific Sysmon Event ID")
    parser.add_argument("--suspicious-only", action="store_true", help="Only output events flagged as suspicious")
    args = parser.parse_args()

    # Parse the XML file
    try:
        tree = ET.parse(args.input)
        root = tree.getroot()
    except ET.ParseError as e:
        print(f"[ERROR] Could not parse XML: {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(f"[ERROR] File not found: {args.input}", file=sys.stderr)
        sys.exit(1)

    # Find all Event elements
    events = root.findall(f".//{{{SYSMON_NS}}}Event")
    print(f"[*] Found {len(events)} total events", file=sys.stderr)

    parsed_events = []
    for event_el in events:
        parsed = parse_event(event_el)
        parsed = flag_suspicious(parsed)

        # Apply filters
        if args.event_id and parsed.get("event_id") != args.event_id:
            continue
        if args.suspicious_only and not parsed.get("requires_review"):
            continue

        parsed_events.append(parsed)

    print(f"[*] Outputting {len(parsed_events)} events after filtering", file=sys.stderr)

    # Output
    output_json = json.dumps(parsed_events, indent=2, default=str)
    if args.output:
        with open(args.output, "w") as f:
            f.write(output_json)
        print(f"[+] Written to {args.output}", file=sys.stderr)
    else:
        print(output_json)


if __name__ == "__main__":
    main()

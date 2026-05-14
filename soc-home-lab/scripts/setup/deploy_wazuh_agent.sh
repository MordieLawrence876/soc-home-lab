#!/bin/bash
# =============================================================
# deploy_wazuh_agent.sh
# Wazuh Agent Automated Deployment Script
# =============================================================
# Author: Mordie Lawrence
# Purpose: Automate Wazuh agent installation and enrollment
#          on a new Ubuntu/Debian endpoint
#
# BEFORE RUNNING THIS SCRIPT, UNDERSTAND:
#   A Wazuh agent is software installed on each monitored system.
#   It collects logs, monitors file integrity, and runs security
#   checks — then ships everything to the Wazuh Manager (your SIEM).
#   This script automates a process you'd run on every new endpoint.
#
# USAGE:
#   chmod +x deploy_wazuh_agent.sh
#   sudo ./deploy_wazuh_agent.sh
#
# WHAT TO CHANGE:
#   Set WAZUH_MANAGER_IP to the IP of your Wazuh Manager VM
# =============================================================

set -euo pipefail   # Exit on error, undefined vars, pipe failures

# ---- CONFIGURATION — Edit these ----
WAZUH_MANAGER_IP="192.168.56.10"    # Change to your Wazuh Manager VM IP
WAZUH_AGENT_NAME="$(hostname)"      # Uses machine hostname as agent name
WAZUH_VERSION="4.7"

# ---- Color output helpers ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ---- Preflight checks ----
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (sudo)"
    exit 1
fi

if [[ "$WAZUH_MANAGER_IP" == "192.168.56.10" ]]; then
    log_warn "Using default manager IP. Edit WAZUH_MANAGER_IP before running in production."
fi

log_info "Starting Wazuh Agent deployment on: $(hostname)"
log_info "Wazuh Manager target: ${WAZUH_MANAGER_IP}"

# ---- Install dependencies ----
log_info "Updating package list..."
apt-get update -qq

log_info "Installing prerequisites..."
apt-get install -y curl apt-transport-https lsb-release gnupg2

# ---- Add Wazuh repository ----
log_info "Adding Wazuh APT repository..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WUH | gpg --no-default-keyring \
    --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] \
    https://packages.wazuh.com/4.x/apt/ stable main" \
    | tee /etc/apt/sources.list.d/wazuh.list

apt-get update -qq

# ---- Install Wazuh Agent ----
log_info "Installing Wazuh Agent ${WAZUH_VERSION}..."
WAZUH_MANAGER="${WAZUH_MANAGER_IP}" \
WAZUH_AGENT_NAME="${WAZUH_AGENT_NAME}" \
apt-get install -y wazuh-agent

# ---- Enable and start service ----
log_info "Enabling Wazuh Agent service..."
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

# ---- Verify installation ----
if systemctl is-active --quiet wazuh-agent; then
    log_info "Wazuh Agent installed and running successfully"
    log_info "Agent name: ${WAZUH_AGENT_NAME}"
    log_info "Reporting to: ${WAZUH_MANAGER_IP}"
    log_info ""
    log_info "NEXT STEPS:"
    log_info "  1. Go to Wazuh Manager dashboard"
    log_info "  2. Navigate to Agents > Pending Agents"
    log_info "  3. Accept and activate: ${WAZUH_AGENT_NAME}"
else
    log_error "Wazuh Agent failed to start. Check: journalctl -u wazuh-agent -n 50"
    exit 1
fi

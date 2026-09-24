#!/bin/bash
#
# generate_trace.sh  –  NS3 WiFi Lab trace generator
#
# USAGE:
#   bash generate_trace.sh <YOUR_ROLL_NUMBER>
#
# Examples (IITB roll number formats all work):
#   bash generate_trace.sh 25m0822
#   bash generate_trace.sh 23b876
#   bash generate_trace.sh 25D0042
#   bash generate_trace.sh 210050042
#
# This runs a genuine NS3 802.11b WiFi infrastructure-mode simulation whose
# parameters are UNIQUELY DERIVED FROM YOUR ROLL NUMBER.
#
# NOTE: The first time you run this, NS3 will be compiled from source.
# This takes ~10-15 minutes. Subsequent runs skip the build and are fast.
#
# Output files (written to the lab directory):
#   ns3-ap.pcap   – Access Point's radio capture  (beacons, association, ACKs)
#   ns3-sta.pcap  – Station's radio capture        (beacons + all traffic incl. data)
#
# Analyse these files with tshark and answer the questions in questions.txt.
# Running this script again with the SAME roll number produces the EXACT SAME
# trace (the simulation is deterministic).
#

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: bash generate_trace.sh <roll_number>"
    echo "Examples:"
    echo "  bash generate_trace.sh 25m0822"
    echo "  bash generate_trace.sh 23b876"
    exit 1
fi

ROLL="$1"

# ── Extract a numeric seed from the roll number ───────────────────────────────
# Strip everything that is not a digit (handles formats like 25m0822, 23b876,
# 25D0042, 210050042, etc.).  All digit groups are concatenated in order.
# Example: "25m0822"  →  "250822"
#          "23b876"   →  "23876"
#          "25D0042"  →  "250042"
ROLL_NUM=$(printf '%s' "$ROLL" | tr -cd '0-9')

if [ -z "$ROLL_NUM" ]; then
    echo "ERROR: Roll number must contain at least some digits (e.g. 25m0822)."
    exit 1
fi

# Force decimal interpretation to avoid octal misparse (e.g. "0822" → 822).
ROLL_INT=$(printf '%d' "$((10#$ROLL_NUM))")
if [ "$ROLL_INT" -eq 0 ]; then
    ROLL_INT=1
fi

# ── Simulation parameters derived from roll number ────────────────────────────
RNG_RUN=$(( (ROLL_INT % 9999) + 1 ))        # 1  – 9999
N_PACKETS=$(( 20 + (ROLL_INT % 31) ))        # 20 – 50  packets
PAYLOAD_SZ=$(( 500 + (ROLL_INT % 1001) ))    # 500 – 1500 bytes

# 4 IEEE 802.11b DSSS PHY rate modes – which one depends on roll number.
# (The wifi-simple-infra example uses the Yans 802.11b PHY model;
# ERP-OFDM/802.11g modes are not supported by this example.)
PHY_MODES=(
    "DsssRate1Mbps"
    "DsssRate2Mbps"
    "DsssRate5_5Mbps"
    "DsssRate11Mbps"
)
PHY_MODE=${PHY_MODES[$(( ROLL_INT % ${#PHY_MODES[@]} ))]}

# ── Determine lab directory ───────────────────────────────────────────────────
# Prefer the platform-supplied $LAB_DIRECTORY env var; fall back to the
# directory containing this script so it works even without the env var.
LAB_DIR="${LAB_DIRECTORY:-$(dirname "$(readlink -f "$0")")}"
WIFI_SIM="$LAB_DIR/bin/wifi-sim"
SETUP_SCRIPT="$(dirname "$(readlink -f "$0")")/setup_ns3.sh"

echo "========================================"
echo "  NS3 WiFi Lab – Trace Generator"
echo "========================================"
echo "  Roll number    : $ROLL"
echo "  Numeric seed   : $ROLL_INT"
echo "  RNG run        : $RNG_RUN"
echo "  Packets        : $N_PACKETS"
echo "  Packet size    : $PAYLOAD_SZ bytes"
echo "  PHY mode       : $PHY_MODE"
echo "  Output dir     : $LAB_DIR"
echo ""
echo "This script runs the NS3 network simulator with parameters"
echo "derived from your roll number.  The exact NS3 command is:"
echo ""
echo "  wifi-sim \\"
echo "    --RngRun=$RNG_RUN \\"
echo "    --packetSize=$PAYLOAD_SZ \\"
echo "    --numPackets=$N_PACKETS \\"
echo "    --interval=0.5s \\"
echo "    --phyMode=$PHY_MODE"
echo ""
echo "You can run this command yourself (see questions.txt for ideas)."
echo ""

# ── Build wifi-sim on first run if not yet compiled ───────────────────────────
if [ ! -x "$WIFI_SIM" ]; then
    echo "wifi-sim not found. Running first-time NS3 build (~10-15 minutes)..."
    echo ""
    if [ ! -f "$SETUP_SCRIPT" ]; then
        echo "ERROR: setup_ns3.sh not found at $SETUP_SCRIPT"
        echo "       Make sure you are running inside the NS3 lab container."
        exit 1
    fi
    bash "$SETUP_SCRIPT"
    echo ""
fi

if [ ! -x "$WIFI_SIM" ]; then
    echo "ERROR: NS3 build failed. Binary not found at $WIFI_SIM"
    echo "       Check the output above for errors, or contact the instructor."
    exit 1
fi

# Remove any leftover trace files from a previous run
rm -f "${LAB_DIR}"/ns3-ap*.pcap \
      "${LAB_DIR}"/ns3-sta*.pcap \
      "${LAB_DIR}"/wifi-simple-infra*.pcap 2>/dev/null || true

echo "Running NS3 simulation (15-60 seconds)..."
echo ""

# The simulation writes pcap files to the CURRENT DIRECTORY, so cd there first.
# wifi-simple-infra parameters used:
#   --packetSize  : application payload in bytes
#   --numPackets  : number of UDP packets the STA sends
#   --interval    : inter-packet gap (fixed at 0.5 s)
#   --phyMode     : WiFi 802.11 PHY rate
#   --RngRun      : global ns3 RNG run number (seeds all randomness)
cd "$LAB_DIR"
if ! "$WIFI_SIM" \
        --RngRun="$RNG_RUN" \
        --packetSize="$PAYLOAD_SZ" \
        --numPackets="$N_PACKETS" \
        --interval="0.5s" \
        --phyMode="$PHY_MODE" \
        2>&1; then
    echo ""
    echo "ERROR: NS3 simulation exited with an error."
    echo "       This should not happen with the default parameters."
    echo "       Contact the lab instructor."
    exit 1
fi

echo ""

# ── Rename pcap files to friendly names ───────────────────────────────────────
# ns3 names them: wifi-simple-infra-{nodeId}-{deviceId}.pcap
#   node 0 = AP  →  wifi-simple-infra-0-0.pcap  →  ns3-ap.pcap
#   node 1 = STA →  wifi-simple-infra-1-0.pcap  →  ns3-sta.pcap
AP_RAW=$(ls "${LAB_DIR}/wifi-simple-infra-0-0.pcap" 2>/dev/null || true)
STA_RAW=$(ls "${LAB_DIR}/wifi-simple-infra-1-0.pcap" 2>/dev/null || true)

# Fallback: pick by alphabetical order if exact names differ
if [ -z "$AP_RAW" ]; then
    AP_RAW=$(ls "${LAB_DIR}"/wifi-simple-infra*.pcap 2>/dev/null | sort | head -1 || true)
fi
if [ -z "$STA_RAW" ]; then
    STA_RAW=$(ls "${LAB_DIR}"/wifi-simple-infra*.pcap 2>/dev/null | sort | tail -1 || true)
fi

if [ -z "$AP_RAW" ]; then
    echo "ERROR: Simulation did not produce any pcap files."
    echo "       Check the simulation output above for errors."
    exit 1
fi

mv "$AP_RAW"  "${LAB_DIR}/ns3-ap.pcap"
[ -n "$STA_RAW" ] && [ "$STA_RAW" != "$AP_RAW" ] && \
    mv "$STA_RAW" "${LAB_DIR}/ns3-sta.pcap" || true
rm -f "${LAB_DIR}"/wifi-simple-infra*.pcap 2>/dev/null || true
chmod 644 "${LAB_DIR}"/ns3-*.pcap 2>/dev/null || true

echo "========================================"
echo "  Trace files ready:"
ls -lh "${LAB_DIR}"/ns3-*.pcap 2>/dev/null
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Read questions.txt"
echo "  2. Use tshark to analyse the traces"
echo "  3. Write your answers in answer.txt"
echo ""
echo "Quick reference – useful tshark commands:"
printf '  %-55s  # %s\n' \
    "tshark -r ns3-ap.pcap" "list all frames" \
    "tshark -r ns3-ap.pcap  -Y 'wlan.fc.type_subtype==8'" "beacon frames" \
    "tshark -r ns3-ap.pcap  -Y 'wlan.fc.type==0'"         "management frames" \
    "tshark -r ns3-ap.pcap  -Y 'wlan.fc.type==1'"         "control frames" \
    "tshark -r ns3-sta.pcap -Y 'wlan.fc.type==2'"         "data frames (STA trace)" \
    "tshark -r ns3-sta.pcap -Y 'udp'"                     "UDP packets (STA trace)"

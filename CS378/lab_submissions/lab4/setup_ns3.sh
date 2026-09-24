#!/bin/bash
#
# setup_ns3.sh  –  Build the NS3 wifi-sim binary from source
#
# USAGE:
#   bash setup_ns3.sh
#
# This compiles the NS3 wifi-simple-infra example for your machine.
# It runs ONCE (~10-15 minutes).  After that, generate_trace.sh finds
# the binary and skips the build automatically.
#
# The binary is saved to:
#   /home/labDirectory/bin/wifi-sim
#
# This path is inside your persistent lab directory, so it survives
# container restarts.
#

set -euo pipefail

LAB_DIR="${LAB_DIRECTORY:-/home/labDirectory}"
BUILD_DIR="$LAB_DIR/ns3-build"
BIN_DIR="$LAB_DIR/bin"
WIFI_SIM="$BIN_DIR/wifi-sim"
NS3_TARBALL="/opt/ns-allinone-3.41.tar.bz2"
NS3_SRC="$BUILD_DIR/ns-allinone-3.41/ns-3.41"

# ── Already built? ────────────────────────────────────────────────────────────
if [ -x "$WIFI_SIM" ]; then
    echo "wifi-sim is already compiled."
    echo "  Binary : $WIFI_SIM"
    echo "  Size   : $(du -sh "$WIFI_SIM" | cut -f1)"
    echo ""
    echo "Nothing to do. Run  bash generate_trace.sh <YOUR_ROLL_NUMBER>  when ready."
    exit 0
fi

# ── Sanity checks ─────────────────────────────────────────────────────────────
if [ ! -f "$NS3_TARBALL" ]; then
    echo "ERROR: NS3 source tarball not found at $NS3_TARBALL"
    echo "       You must run this inside the NS3 lab container."
    exit 1
fi

for tool in g++ cmake ninja python3; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: Required build tool '$tool' is not installed."
        echo "       You must run this inside the NS3 lab container."
        exit 1
    fi
done

# ── Print what we're about to do ─────────────────────────────────────────────
echo "========================================"
echo "  NS3 First-Time Setup"
echo "  Building wifi-sim from source"
echo ""
echo "  Estimated time : 10-15 minutes"
echo "  Output         : $WIFI_SIM"
echo "  Build tree     : $BUILD_DIR  (~2 GB)"
echo "========================================"
echo ""

mkdir -p "$BUILD_DIR" "$BIN_DIR"

# ── Extract source ────────────────────────────────────────────────────────────
if [ ! -d "$NS3_SRC" ]; then
    echo "[1/3] Extracting NS3 source (~1 minute) ..."
    tar -xjf "$NS3_TARBALL" -C "$BUILD_DIR"
    echo "      Done."
    echo ""
else
    echo "[1/3] NS3 source already extracted. Skipping."
    echo ""
fi

cd "$NS3_SRC"

# ── Configure ─────────────────────────────────────────────────────────────────
echo "[2/3] Configuring NS3 (~3 minutes) ..."
echo "      (using -march=x86-64 so the binary runs on every cluster node)"
echo ""
CXXFLAGS="-O3 -march=x86-64" ./ns3 configure \
    --enable-examples \
    --disable-python \
    --disable-tests \
    --build-profile=optimized 2>&1
echo ""

# ── Build ─────────────────────────────────────────────────────────────────────
echo "[3/3] Building wifi-simple-infra (~8 minutes) ..."
echo ""
./ns3 build examples/wireless/wifi-simple-infra 2>&1
echo ""

# ── Install binary ────────────────────────────────────────────────────────────
BINARY=$(find build/examples/wireless -name '*wifi-simple-infra*' -type f 2>/dev/null | head -1 || true)
if [ -z "$BINARY" ]; then
    echo "ERROR: Build appeared to succeed but the binary was not found."
    echo "       Check the output above for compiler errors."
    exit 1
fi

cp "$BINARY" "$WIFI_SIM"
chmod +x "$WIFI_SIM"

echo "========================================"
echo "  Build complete!"
echo "  Binary : $WIFI_SIM"
echo "  Size   : $(du -sh "$WIFI_SIM" | cut -f1)"
echo "========================================"
echo ""
echo "Now run:  bash generate_trace.sh <YOUR_ROLL_NUMBER>"
echo ""

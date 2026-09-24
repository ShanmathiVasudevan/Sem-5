#!/bin/bash
#
# generate_trace.sh (p3 -- Metrics)
#
# Runs once, automatically, at container boot. Downloads a real file
# over plain HTTP (for the Throughput module) and pings a real host
# (for the Latency module), capturing everything into trace.pcapng.
# Also saves the real wget/ping command output as text files, since
# the questions ask you to compare what you measured in the trace
# against what those tools reported directly.
#
# The package to download and the ping target are picked
# deterministically based on CLAB_USER_NAME (same student always gets
# the same trace).

set -uo pipefail

CLAB_USER_NAME="${CLAB_USER_NAME:-}"
if [ -z "$CLAB_USER_NAME" ]; then
    echo "WARNING: CLAB_USER_NAME is not set -- falling back to hostname." >&2
    CLAB_USER_NAME="$(hostname)"
fi

TRACE_FILE="$HOME/trace.pcapng"
LAB_DIR="/home/labDirectory"
WGET_OUTPUT="$LAB_DIR/wget_output.txt"
PING_OUTPUT="$LAB_DIR/ping_output.txt"

seeded_shuffle() {
    local salt="$1"; shift
    local item h
    for item in "$@"; do
        h=$(printf '%s' "${CLAB_USER_NAME}:${salt}:${item}" | sha256sum | cut -c1-16)
        echo "$h $item"
    done | sort | awk '{print $2}'
}

seeded_pick_one() {
    local salt="$1"; shift
    seeded_shuffle "$salt" "$@" | head -n1
}

# Packages available in the Ubuntu main pool over plain HTTP -- picked
# to be small-ish (a few hundred KB to a few MB), single-file, and
# stable/version-independent via `apt-get download` (no hardcoded
# version string to go stale). Plain HTTP is deliberate: the Content-
# Length needs to be visible in cleartext in the trace, which would
# not be the case over HTTPS.
PACKAGES=(vim-common less htop tree jq tmux unzip curl)
PACKAGE="$(seeded_pick_one "p3-package" "${PACKAGES[@]}")"

PING_TARGETS=(www.cse.iitb.ac.in iitb.ac.in google.com)

print_capture_diagnostics() {
    echo "----- capture diagnostics -----" >&2
    echo "whoami: $(whoami 2>&1)" >&2
    echo "id: $(id 2>&1)" >&2
    echo "effective capabilities (see 'capsh --decode=<hex>' to read):" >&2
    grep -E '^Cap(Inh|Prm|Eff|Bnd)' /proc/self/status 2>&1 >&2
    echo "ip -o link show:" >&2
    ip -o link show 2>&1 >&2
    echo "tshark -D:" >&2
    tshark -D 2>&1 >&2
    echo "dumpcap -D:" >&2
    dumpcap -D 2>&1 >&2
    echo "--------------------------------" >&2
    echo "If every interface (including 'any') fails with ioctl/setsockopt" >&2
    echo "errors like SIOCETHTOOL or SO_TIMESTAMPNS while running as root," >&2
    echo "this is usually NOT a script bug -- it means the container's" >&2
    echo "network stack does not support raw packet capture at all. This" >&2
    echo "is a known limitation on some Docker Desktop for Mac networking" >&2
    echo "modes. Check: (1) the container is run with --cap-add=NET_RAW" >&2
    echo "--cap-add=NET_ADMIN, (2) if running on Docker Desktop for Mac," >&2
    echo "try a real Linux Docker host, or a different Docker Desktop" >&2
    echo "network backend." >&2
}

candidate_interfaces() {
    local route_iface up_iface
    route_iface="$(ip -o route get 8.8.8.8 2>/dev/null \
        | awk '{for(i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}')"
    up_iface="$(ip -o link show up 2>/dev/null \
        | awk -F': ' '{print $2}' | cut -d'@' -f1 | grep -v '^lo$' | head -n1)"

    local seen=" "
    for cand in "$route_iface" "eth0" "$up_iface"; do
        if [ -n "$cand" ] && [[ "$seen" != *" $cand "* ]]; then
            echo "$cand"
            seen="$seen$cand "
        fi
    done
    echo "any"
}

# ---------------------------------------------------------------------------
# Start a packet capture on the given interface, trying several
# strategies in turn -- see p1's generate_trace.sh for the full
# rationale (some container network runtimes reject the
# ETHTOOL_GET_TS_INFO ioctl / SO_TIMESTAMPNS setsockopt libpcap uses
# by default, which is fatal to a plain "tshark -i ... -w ..." even
# though capture would otherwise work fine).
#
# Sets the globals CAPTURE_PID and CAPTURE_METHOD on success.
# ---------------------------------------------------------------------------
CAPTURE_PID=""
CAPTURE_METHOD=""

start_capture() {
    local iface="$1" file="$2" log="/tmp/capture_attempt.log"
    local pid

    rm -f "$file"
    tshark -i "$iface" --time-stamp-type host -w "$file" -q > "$log" 2>&1 &
    pid=$!
    sleep 3
    if kill -0 "$pid" 2>/dev/null; then
        CAPTURE_PID="$pid"; CAPTURE_METHOD="tshark --time-stamp-type host"
        return 0
    fi
    echo "Capture method 'tshark --time-stamp-type host' failed on '$iface':" >&2
    cat "$log" >&2

    rm -f "$file"
    tcpdump -i "$iface" -j host -w "$file" > "$log" 2>&1 &
    pid=$!
    sleep 3
    if kill -0 "$pid" 2>/dev/null; then
        CAPTURE_PID="$pid"; CAPTURE_METHOD="tcpdump -j host"
        return 0
    fi
    echo "Capture method 'tcpdump -j host' failed on '$iface':" >&2
    cat "$log" >&2

    rm -f "$file"
    tcpdump -i "$iface" -w "$file" > "$log" 2>&1 &
    pid=$!
    sleep 3
    if kill -0 "$pid" 2>/dev/null; then
        CAPTURE_PID="$pid"; CAPTURE_METHOD="tcpdump (default)"
        return 0
    fi
    echo "Capture method 'tcpdump (default)' failed on '$iface':" >&2
    cat "$log" >&2

    rm -f "$file"
    tshark -i "$iface" -w "$file" -q > "$log" 2>&1 &
    pid=$!
    sleep 3
    if kill -0 "$pid" 2>/dev/null; then
        CAPTURE_PID="$pid"; CAPTURE_METHOD="tshark (default)"
        return 0
    fi
    echo "Capture method 'tshark (default)' failed on '$iface':" >&2
    cat "$log" >&2

    return 1
}

capture_and_generate_traffic() {
    local iface="$1"
    local dl_dir download_url

    dl_dir="$(mktemp -d)"

    # The image's apt package index is deleted at build time (standard
    # image-size hygiene) -- refresh it here so `apt-get download
    # --print-uris` below actually has something to resolve against.
    # Without this, download_url comes back empty and this whole
    # module silently has nothing to work with.
    apt-get update > /dev/null 2>&1

    # Resolve the exact URL apt would use for this package on this
    # system, WITHOUT downloading it yet -- so we can hand that exact
    # URL to wget for the actual (captured) download.
    download_url="$(cd "$dl_dir" && apt-get download --print-uris "$PACKAGE" 2>/dev/null \
        | head -n1 | cut -d"'" -f2)"
    if [ -z "$download_url" ]; then
        echo "Could not resolve a download URL for package '$PACKAGE'"
        rm -rf "$dl_dir"
        return 1
    fi

    if ! start_capture "$iface" "$TRACE_FILE"; then
        echo "All capture methods failed on interface '$iface'"
        rm -rf "$dl_dir"
        return 1
    fi
    local capture_pid="$CAPTURE_PID"
    echo "Capture method: $CAPTURE_METHOD"

    echo "Interface: $iface"
    echo "Package: $PACKAGE"
    echo "Download URL: $download_url"

    # --- Module 1: Throughput ---
    ( cd "$dl_dir" && wget "$download_url" -O downloaded_file ) \
        > "$WGET_OUTPUT" 2>&1 || true

    sleep 1

    # --- Module 2: Latency ---
    #
    # No single public IP is guaranteed reachable from every network
    # (some institutional networks have routing/peering gaps to
    # specific providers, e.g. Quad9's 9.9.9.9 was found to be
    # unreachable -- 100% packet loss -- from one deployment network
    # even though outbound ICMP itself worked fine). Rather than trust
    # one seeded pick, try each candidate (in seeded order, so still
    # deterministic per student) until one actually returns replies,
    # verified from ping's own reported receive count -- not just
    # whether the command ran.
    mapfile -t ping_order < <(seeded_shuffle "p3-ping-target" "${PING_TARGETS[@]}")
    ping_target_used=""
    for candidate in "${ping_order[@]}"; do
        echo "Trying ping target: $candidate"
        ping_out="$(ping -i 1 -c 11 "$candidate" 2>&1)"
        received="$(echo "$ping_out" | grep -oE '[0-9]+ received' | grep -oE '^[0-9]+')"
        if [ -n "$received" ] && [ "$received" -ge 2 ]; then
            echo "$ping_out" > "$PING_OUTPUT"
            ping_target_used="$candidate"
            echo "Got $received replies from $candidate -- using this target"
            break
        fi
        echo "No usable replies from $candidate ($received received) -- trying next candidate"
    done
    if [ -z "$ping_target_used" ]; then
        echo "None of the candidate ping targets returned replies from this network"
    fi

    sleep 3
    kill -INT "$capture_pid" 2>/dev/null
    wait "$capture_pid" 2>/dev/null
    rm -rf "$dl_dir"

    if [ ! -s "$TRACE_FILE" ]; then
        echo "No trace file produced on interface '$iface'"
        return 1
    fi

    local http_ok_count icmp_req_count icmp_reply_count
    http_ok_count=$(tshark -r "$TRACE_FILE" -Y "http.response.code==200" -T fields -e frame.number 2>/dev/null | wc -l)
    icmp_req_count=$(tshark -r "$TRACE_FILE" -Y "icmp.type==8" -T fields -e frame.number 2>/dev/null | wc -l)
    icmp_reply_count=$(tshark -r "$TRACE_FILE" -Y "icmp.type==0" -T fields -e frame.number 2>/dev/null | wc -l)

    echo "Captured: http_200=$http_ok_count icmp_request=$icmp_req_count icmp_reply=$icmp_reply_count on interface '$iface'"

    if [ "$http_ok_count" -lt 1 ]; then
        echo "No successful HTTP download visible on interface '$iface'"
        return 1
    fi
    if [ "$icmp_req_count" -lt 2 ] || [ "$icmp_reply_count" -lt 2 ]; then
        echo "Not enough ICMP request/reply pairs on interface '$iface' (need at least 2 of each for the RTT questions)"
        return 1
    fi

    return 0
}

success=0
while read -r iface; do
    if capture_and_generate_traffic "$iface"; then
        success=1
        break
    fi
done < <(candidate_interfaces)

if [ "$success" -ne 1 ]; then
    print_capture_diagnostics
    echo "ERROR: could not capture the required HTTP download + ICMP request/reply traffic on any candidate interface" >&2
    exit 1
fi

chmod 644 "$TRACE_FILE" "$WGET_OUTPUT" "$PING_OUTPUT" 2>/dev/null
echo "Trace saved to $TRACE_FILE"
echo "wget output saved to $WGET_OUTPUT"
echo "ping output saved to $PING_OUTPUT"

# NS3 WiFi Infrastructure Lab

## Overview

In this lab you will run a real network simulator (NS3) to generate 802.11b
WiFi packet captures, then analyse them with tshark to answer questions about
WiFi frame types and infrastructure-mode behaviour.

Each student's simulation is seeded with their roll number, so every student
gets a different (but deterministic) trace.

---

## Step 1 – Generate your trace

Open a terminal inside the lab container and run:

```
bash generate_trace.sh <YOUR_ROLL_NUMBER>
```

Example:
```
bash generate_trace.sh 24B0901
```

**Important – first-run build (10-15 minutes):**
The NS3 simulator is compiled from source the first time you run the script.
This is a one-time step that takes approximately 10-15 minutes.
Do not close the terminal or stop the process.
You will see compiler output scrolling by – this is normal.
Once the build finishes, the simulation itself runs in under a minute.

On every subsequent run (same or different roll number), the build is skipped
and the simulation starts immediately.

After the script finishes you will have two pcap files in your lab directory:

| File | What it captures |
|---|---|
| `ns3-ap.pcap` | Access Point radio — beacons, association exchange, ACKs |
| `ns3-sta.pcap` | Station radio — everything the STA sends and receives |

---

## Step 2 – Analyse with tshark

tshark is pre-installed in the container.  Use it to inspect the pcap files.

**Count all frames:**
```
tshark -r ns3-ap.pcap -T fields -e frame.number | wc -l
```

**Filter by frame type:**
```
tshark -r ns3-ap.pcap -Y 'wlan.fc.type_subtype == 8'    # beacons
tshark -r ns3-ap.pcap -Y 'wlan.fc.type == 0'            # management frames
tshark -r ns3-ap.pcap -Y 'wlan.fc.type == 1'            # control frames
tshark -r ns3-sta.pcap -Y 'wlan.fc.type == 2'           # data frames
tshark -r ns3-sta.pcap -Y 'udp'                         # UDP packets
```

**Read a field value:**
```
tshark -r ns3-sta.pcap -Y 'udp' -T fields -e frame.len | head -1
tshark -r ns3-ap.pcap -T fields -e frame.time_relative | tail -1
```

You can also open the pcap files in Wireshark if it is available on your
machine (copy the files out of the container first).

---

## Step 3 – Answer the questions

Open `questions.txt` and answer each question by editing `answer.txt`.
Write answers in the form:
```
ROLL=<YOUR_ROLL_NUMBER>
Q1=42
Q14=A
```

For Q14–Q20 write only the option letter.
For Q8 round to the nearest whole second.
For Q13 give the answer in milliseconds, rounded to the nearest integer.

---

## Background – 802.11 Frame Types

The IEEE 802.11 Frame Control field has a 2-bit **Type** and a 4-bit **Subtype**:

| Type value | Category | Examples |
|---|---|---|
| 0 | Management | Beacon (subtype 8), Assoc Req (0), Assoc Resp (1) |
| 1 | Control | ACK (subtype 13) |
| 2 | Data | Data frames carrying IP/UDP payload |

In **infrastructure mode** (AP + STA):
- The AP broadcasts **Beacon** frames periodically to announce itself.
- The STA sends an **Association Request** to join; the AP replies with an **Association Response**.
- All data traffic passes through the AP, even between two STAs on the same network.

---

## Simulation details

The NS3 example used is `wifi-simple-infra` with the Yans 802.11b DSSS PHY.
Two nodes are simulated: node 0 is the AP, node 1 is the STA.
The STA sends UDP packets to a broadcast address through the AP.
Simulation parameters (number of packets, packet size, PHY rate) are derived
from your roll number so every student's trace is unique.

#!/usr/bin/env python3
import json
import struct
import matplotlib.pyplot as plt

def hex_to_float(h):
    """Convert a hex string like '0x3f800000' to a Python float."""
    i = int(h, 16)
    # pack as 32-bit unsigned big-endian, unpack as IEEE-754 float
    return struct.unpack('!f', struct.pack('!I', i))[0]

# --- Load raw hex data ---
with open("inputs/stimuli.json")       as f: raw_inputs = json.load(f)
with open("outputs/golden_output.json") as f: raw_ref    = json.load(f)
with open("outputs/dut_output.json")    as f: raw_dut    = json.load(f)

# --- Convert to floats ---
inputs = [hex_to_float(h) for h in raw_inputs]
ref    = [hex_to_float(h) for h in raw_ref]
dut    = [hex_to_float(h) for h in raw_dut]

# --- Compare ---
n = min(len(ref), len(dut))
inputs = inputs[:n]
ref    = ref[:n]
dut    = dut[:n]

mismatches = [(i, ref[i], dut[i]) for i in range(n) if abs(ref[i] - dut[i]) > 1.0]
if mismatches:
    print(f"[FAIL] {len(mismatches)}/{n} mismatches:")
    for i, r, d in mismatches[:10]:
        print(f"  idx={i}: ref={r:.6f}  dut={d:.6f}")
else:
    print(f"[PASS] All {n} samples match within ±1 tolerance")

# --- Plot ---
plt.figure(figsize=(8,4))
x = list(range(n))
plt.plot(x, inputs, marker='o', linestyle='-', label='Input')
plt.plot(x, ref,    marker='s', linestyle='--', label='Golden Output')
plt.plot(x, dut,    marker='^', linestyle=':', label='DUT')
plt.xlabel("Sample Index")
plt.ylabel("Value")
plt.title("High Pass Filter Response")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

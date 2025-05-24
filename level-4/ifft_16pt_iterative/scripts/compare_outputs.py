#!/usr/bin/env python3
import json
import matplotlib.pyplot as plt

# --- Load data ---
inputs = json.load(open("inputs/stimuli.json"))
ref    = json.load(open("outputs/golden_output.json"))
dut    = json.load(open("outputs/dut_output.json"))

# --- Compare ---
n      = min(len(ref), len(dut))
inputs = inputs[:n]
ref = ref[:n]
dut = dut[:n]
mismatches = [(i, ref[i], dut[i]) for i in range(n) if abs(ref[i] - dut[i]) > 1]

if mismatches:
    print(f"[FAIL] {len(mismatches)}/{n} mismatches:")
    for i,r,d in mismatches[:10]:
        print(f"  idx={i}: ref={r}  dut={d}")
else:
    print(f"[PASS] All {n} samples match")

# --- Plot ---
plt.figure(figsize=(8,4))
x = list(range(len(inputs)))
plt.plot(x, inputs, marker='o', linestyle='-', label='Input')
plt.plot(x, ref,    marker='s', linestyle='--', label='Golden Output')
plt.plot(x, dut,    marker='^', linestyle=':', label='DUT')
plt.xlabel("Sample Index")
plt.ylabel("Value")
plt.title("16 Point Iterative IFFT")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

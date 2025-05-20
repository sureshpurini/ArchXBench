#!/usr/bin/env python3
import json
import numpy as np
import matplotlib.pyplot as plt
import sys

# --- Load data ---
try:
    inputs = json.load(open("inputs/stimuli.json"))
    ref    = json.load(open("outputs/golden_output.json"))
    dut    = json.load(open("outputs/dut_output.json"))
except Exception as e:
    print(f"[ERROR] Failed to load JSON files: {e}")
    sys.exit(1)

# --- Basic check ---
n_in  = len(inputs)
n_ref = len(ref)
n_dut = len(dut)
if n_ref != n_dut:
    print(f"[WARN] Reference length ({n_ref}) != DUT length ({n_dut})")
# infer image dimensions (assume square)
w = int(n_in**0.5)
h = w
if w*h != n_in:
    print(f"[ERROR] Cannot reshape {n_in} samples into square image")
    sys.exit(1)

w_dut = int(n_dut**0.5)
h_dut = w_dut
if w_dut*h_dut != n_dut:
    print(f"[ERROR] Cannot reshape {n_dut} samples into square image")
    sys.exit(1)

# --- Reshape to 2D images ---
inp_img = np.array(inputs).reshape((h, w))
ref_img = np.array(ref).reshape((h, w))
dut_img = np.array(dut).reshape((h_dut, w_dut))

# --- Plot as subplots ---
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
for ax, img, title in zip(axes, [inp_img, ref_img, dut_img], ["Input", "Golden Output", "DUT"]):
    ax.imshow(img, cmap='gray', vmin=0, vmax=255)
    ax.set_title(title)
    ax.axis('off')

plt.suptitle("2D Convolution")
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()

import json
import numpy as np
import os

VLEN = 8
K = 64
SCALE_Q = 15

np.random.seed(42)

def gen_fp_matrix(shape):
    return np.random.uniform(-1.0, 1.0, size=shape).astype(np.float32)

def gen_scale_q15():
    real = 10**np.random.uniform(-3, -0.3)
    return int(round(real * (1 << SCALE_Q)))

A_fp = gen_fp_matrix((VLEN, K))
B_fp = gen_fp_matrix((K, VLEN))
scale_A = gen_scale_q15()
scale_B = gen_scale_q15()
zp_A = int(np.random.randint(-16, 17))
zp_B = int(np.random.randint(-16, 17))

inputs = {
    "A_fp": A_fp.tolist(),
    "B_fp": B_fp.tolist(),
    "scale_A": scale_A,
    "scale_B": scale_B,
    "scale_q": SCALE_Q,
    "zp_A": zp_A,
    "zp_B": zp_B
}

os.makedirs("inputs", exist_ok=True)
with open("inputs/stimuli.json", "w") as f:
    json.dump(inputs, f, indent=2)

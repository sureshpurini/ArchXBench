import json
import numpy as np

CIN, COUT, K = 3, 8, 3

with open("inputs/stimuli.json") as f:
    data = json.load(f)

img = np.array(data["image"], dtype=np.int32)
kernel = np.ones((COUT, CIN, K, K), dtype=np.int32)
bias = np.zeros((COUT,), dtype=np.int32)

H, W = img.shape[1:]
out = np.zeros((COUT, H-K+1, W-K+1), dtype=np.int32)

for c_out in range(COUT):
    for i in range(H-K+1):
        for j in range(W-K+1):
            acc = bias[c_out]
            for c in range(CIN):
                acc += np.sum(img[c, i:i+K, j:j+K] * kernel[c_out, c])
            out[c_out, i, j] = acc

with open("outputs/golden_output.json", "w") as f:
    json.dump({"C": out.flatten().tolist()}, f, indent=2)

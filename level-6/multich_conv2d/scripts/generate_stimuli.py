import json
import numpy as np

CIN, H, W = 3, 64,64 
np.random.seed(42)
img = np.random.randint(0, 256, size=(CIN, H, W), dtype=np.uint8)

with open("inputs/stimuli.json", "w") as f:
    json.dump({"image": img.tolist()}, f, indent=2)

with open("tb_input.mem", "w") as f:
    for c in range(CIN):
        for i in range(H):
            for j in range(W):
                f.write(f"{img[c,i,j]:02x}\n")

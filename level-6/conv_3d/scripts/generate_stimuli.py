import json
import numpy as np

D, H, W = 8, 64, 64
np.random.seed(42)
volume = np.random.randint(0, 256, size=(D, H, W), dtype=np.uint8)

with open("inputs/stimuli.json", "w") as f:
    json.dump({"volume": volume.tolist()}, f, indent=2)

with open("tb_input.mem", "w") as f:
    flat = volume.flatten()
    for v in flat:
        f.write(f"{v:02x}\n")

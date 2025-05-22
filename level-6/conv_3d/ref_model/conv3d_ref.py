import json
import numpy as np

def conv3d(volume, kernel):
    D, H, W = volume.shape
    kD, kH, kW = kernel.shape
    out_D = D - kD + 1
    out_H = H - kH + 1
    out_W = W - kW + 1
    output = np.zeros((out_D, out_H, out_W), dtype=np.int32)

    for d in range(out_D):
        for i in range(out_H):
            for j in range(out_W):
                patch = volume[d:d+kD, i:i+kH, j:j+kW]
                output[d, i, j] = np.sum(patch * kernel)
    return output

with open("inputs/stimuli.json") as f:
    data = json.load(f)

vol = np.array(data["volume"], dtype=np.int32)
kernel = np.ones((3,3,3), dtype=np.int32)
C = conv3d(vol, kernel)

with open("outputs/golden_output.json", "w") as f:
    json.dump({"C": C.flatten().tolist()}, f, indent=2)

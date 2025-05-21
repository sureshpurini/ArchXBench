import json
import numpy as np

def quantize(x_fp, scale, zp):
    return np.round(x_fp / scale).astype(np.int32) + zp

def dequantize(c_acc, scale_A, scale_B):
    return (scale_A * scale_B * c_acc).astype(np.float32)

def main():
    with open("inputs/stimuli.json") as f:
        d = json.load(f)

    A_fp = np.array(d["A_fp"], dtype=np.float32)
    B_fp = np.array(d["B_fp"], dtype=np.float32)
    scale_A = d["scale_A"] / (1 << d["scale_q"])
    scale_B = d["scale_B"] / (1 << d["scale_q"])
    zp_A = d["zp_A"]
    zp_B = d["zp_B"]

    A_q = quantize(A_fp, scale_A, zp_A)
    B_q = quantize(B_fp, scale_B, zp_B)

    A_zp = A_q - zp_A
    B_zp = B_q - zp_B
    C_acc = A_zp @ B_zp

    C_fp = dequantize(C_acc, scale_A, scale_B)

    with open("outputs/golden_output.json", "w") as f:
        json.dump({ "C": C_fp.tolist() }, f, indent=2)

if __name__ == "__main__":
    main()

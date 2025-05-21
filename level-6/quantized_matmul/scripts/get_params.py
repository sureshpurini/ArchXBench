import json

with open("inputs/stimuli.json") as f:
    d = json.load(f)

# Emit zero-points as 8-bit hex
print(f"{d['zp_A'] & 0xFF:02x}")
print(f"{d['zp_B'] & 0xFF:02x}")

# Emit Q15 fixed-point scales as 16-bit hex
print(f"{d['scale_A'] & 0xFFFF:04x}")
print(f"{d['scale_B'] & 0xFFFF:04x}")

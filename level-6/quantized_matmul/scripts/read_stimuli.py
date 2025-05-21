import json
import struct

def f32_to_hex(val):
    return f"{struct.unpack('<I', struct.pack('<f', val))[0]:08x}"

with open("inputs/stimuli.json") as f:
    data = json.load(f)

for row in data["A_fp"]:
    for val in row:
        print(f32_to_hex(val))

for row in data["B_fp"]:
    for val in row:
        print(f32_to_hex(val))

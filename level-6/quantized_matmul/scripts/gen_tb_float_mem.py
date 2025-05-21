import json
import struct

with open("inputs/stimuli.json") as f:
    d = json.load(f)

def f32_to_hex(f):
    return f"{struct.unpack('<I', struct.pack('<f', f))[0]:08x}"

for row in d["A_fp"]:
    for x in row:
        print(f32_to_hex(x))

for row in d["B_fp"]:
    for x in row:
        print(f32_to_hex(x))

import json

with open("inputs/stimuli.json") as f:
    data = json.load(f)

image = data["image"]  # shape: [CIN][H][W]

for c in range(len(image)):
    for i in range(len(image[0])):
        for j in range(len(image[0][0])):
            print(f"{image[c][i][j]:02x}")

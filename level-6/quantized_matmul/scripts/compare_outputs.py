import json
from itertools import chain

TOL = 1

def load_flat(path):
    with open(path) as f:
        data = json.load(f)["C"]
    return list(chain.from_iterable(data)) if isinstance(data[0], list) else data

ref = load_flat("outputs/golden_output.json")
dut = load_flat("outputs/dut_output.json")

errors = []
for i, (r, d) in enumerate(zip(ref, dut)):
    if abs(r - d) > TOL:
        errors.append({
            "index": i,
            "expected": r,
            "actual": d,
            "difference": abs(r - d),
            "tolerance": TOL
        })

total = len(ref)
mismatches = len(errors)
percent = (100.0 * mismatches / total) if total else 0.0
status = "PASS" if mismatches == 0 else "FAIL"

result = {
    "status": status,
    "total": total,
    "mismatches": mismatches,
    "mismatch_percent": round(percent, 2),
    "tolerance": TOL,
    "errors": errors
}

print(json.dumps(result, indent=2))
print(f"Summary: {mismatches}/{total} mismatches ({percent:.2f}% tolerance={TOL}) → {status}")

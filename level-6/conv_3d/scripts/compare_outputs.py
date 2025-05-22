import json

TOL = 1

with open("outputs/golden_output.json") as f1:
    golden = json.load(f1)["C"]
with open("outputs/dut_output.json") as f2:
    dut = json.load(f2)["C"]

errors = []
matches = 0

for i, (g, d) in enumerate(zip(golden, dut)):
    if abs(g - d) <= TOL:
        matches += 1
    else:
        errors.append({
            "index": i,
            "expected": g,
            "actual": d,
            "difference": abs(g - d),
            "tolerance": TOL
        })

total = len(golden)
match_percent = round(100.0 * matches / total, 2)
mismatch_percent = round(100.0 * len(errors) / total, 2)

result = {
    "status": "PASS" if not errors else "FAIL",
    "total": total,
    "matches": matches,
    "mismatches": len(errors),
    "match_percent": match_percent,
    "mismatch_percent": mismatch_percent,
    "tolerance": TOL,
    "errors": errors
}

print(json.dumps(result, indent=2))

print(f"Summary: {matches}/{total} matched ({match_percent:.2f}%), "
      f"{len(errors)} mismatches ({mismatch_percent:.2f}%), "
      f"TOL={TOL} => {result['status']}")

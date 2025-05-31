import json
TOL = 1

with open("outputs/golden_output.json") as f1:
    g = json.load(f1)["C"]
with open("outputs/dut_output.json") as f2:
    d = json.load(f2)["C"]

match = sum(1 for x, y in zip(g, d) if abs(x - y) <= TOL)
total = len(g)
errors = [{"i": i, "expected": x, "actual": y, "diff": abs(x-y)} for i, (x, y) in enumerate(zip(g, d)) if abs(x - y) > TOL]

print(json.dumps({
    "status": "PASS" if not errors else "FAIL",
    "total": total,
    "matches": match,
    "mismatches": len(errors),
    "match_percent": round(100*match/total, 2),
    "errors": errors
}, indent=2))
print(f"Summary: {match}/{total} matched ({round(100*match/total,2)}%), {len(errors)} mismatches (TOL={TOL})")

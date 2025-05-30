#!/usr/bin/env python3
import json
import sys

def load_json(path):
    """Load a JSON array of hex strings from the given path."""
    try:
        with open(path, 'r') as f:
            data = json.load(f)
        if not isinstance(data, list):
            raise ValueError("Expected a JSON array")
        return data
    except Exception as e:
        print(f"[ERROR] Failed to load '{path}': {e}")
        sys.exit(1)

def compare_hex_lists(dut_list, golden_list):
    """Compare two lists of hex strings element-wise."""
    n_dut = len(dut_list)
    n_golden = len(golden_list)
    n = min(n_dut, n_golden)
    mismatches = []
    for i in range(n):
        d = dut_list[i].strip().lower()
        g = golden_list[i].strip().lower()
        if d != g:
            mismatches.append((i, g, d))
    return mismatches, n_dut, n_golden

def main():
    dut_path    = "outputs/dut_output.json"
    golden_path = "outputs/golden_output.json"

    dut_list    = load_json(dut_path)
    golden_list = load_json(golden_path)

    mismatches, n_dut, n_golden = compare_hex_lists(dut_list, golden_list)

    if n_dut != n_golden:
        print(f"[WARN] Different lengths: DUT has {n_dut} entries, golden has {n_golden} entries")

    if mismatches:
        print(f"[FAIL] {len(mismatches)}/{min(n_dut, n_golden)} mismatches:")
        for i, exp, got in mismatches:
            print(f"  idx={i}: expected {exp}, got {got}")
        sys.exit(1)
    else:
        print(f"[PASS] All {min(n_dut, n_golden)} entries match exactly")
        sys.exit(0)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Check k6 results for performance regression."""

import json
import sys

def main(report_path: str):
    with open(report_path) as f:
        data = json.load(f)

    thresholds = {
        "http_req_duration": {"p(95)": 5000},
        "http_req_failed": {"rate": 0.02},
    }

    passed = True
    for metric_name, checks in data.get("metrics", {}).items():
        if metric_name not in thresholds:
            continue
        for quantile, threshold in thresholds[metric_name].items():
            if quantile == "p(95)":
                value = checks.get("avg", 0)
            elif quantile == "rate":
                value = checks.get("rate", 0)
            else:
                continue
            if value > threshold:
                print(f"FAIL: {metric_name} {quantile}={value} > threshold={threshold}")
                passed = False
            else:
                print(f"PASS: {metric_name} {quantile}={value} <= threshold={threshold}")

    if not passed:
        print("PERFORMANCE REGRESSION DETECTED")
        sys.exit(1)
    else:
        print("All performance checks passed")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: check-regression.py <k6-report.json>")
        sys.exit(1)
    main(sys.argv[1])

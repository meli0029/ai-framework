#!/usr/bin/env python3
"""Check reusable notebook structure; workload correctness needs separate review."""
import argparse
import json
import re
import sys
from pathlib import Path

SENSITIVE_ASSIGNMENT = re.compile(
    r"(?i)(password|client_secret|access_token|api_key|api_token)\s*=\s*['\"][^'\"]+"
)


def source(cell):
    value = cell.get("source", "")
    if isinstance(value, str):
        return value
    if isinstance(value, list) and all(isinstance(line, str) for line in value):
        return "".join(value)
    raise ValueError("cell source must be text or an array of strings")


def validate(notebook, require_lakehouse=False):
    if not isinstance(notebook, dict):
        raise ValueError("notebook must be a JSON object")
    cells = notebook.get("cells", [])
    if not isinstance(cells, list) or not all(isinstance(c, dict) for c in cells):
        raise ValueError("cells must be an array of objects")
    texts = [source(cell) for cell in cells]
    code = [cell for cell in cells if cell.get("cell_type") == "code"]
    checks = {
        "notebook format 4": notebook.get("nbformat") == 4,
        "opening Markdown overview": bool(cells) and cells[0].get("cell_type") == "markdown" and bool(texts[0].strip()),
        "tagged parameters cell second": len(cells) > 1 and cells[1].get("cell_type") == "code"
        and "parameters" in cells[1].get("metadata", {}).get("tags", []),
        "no empty cells": bool(cells) and all(text.strip() for text in texts),
        "outputs cleared": all(not cell.get("outputs") for cell in code),
        "final validation code cell": bool(cells) and cells[-1].get("cell_type") == "code",
        "no literal sensitive assignments": not SENSITIVE_ASSIGNMENT.search("\n".join(texts)),
    }
    if require_lakehouse:
        lakehouse = notebook.get("metadata", {}).get("dependencies", {}).get("lakehouse", {})
        checks["attached default Lakehouse"] = bool(lakehouse.get("default_lakehouse"))
    return checks


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("notebook", type=Path)
    parser.add_argument("--require-lakehouse", action="store_true")
    args = parser.parse_args()
    try:
        checks = validate(json.loads(args.notebook.read_text(encoding="utf-8")), args.require_lakehouse)
    except (OSError, ValueError, TypeError, AttributeError) as exc:
        # Do not echo notebook source: it may contain credentials.
        print(f"Cannot validate notebook ({type(exc).__name__}); check file structure.", file=sys.stderr)
        return 2
    for name, passed in checks.items():
        print(f"{'PASS' if passed else 'FAIL'}  {name}")
    print(f"\n{sum(bool(v) for v in checks.values())}/{len(checks)} checks passed")
    print("Review workload behavior, metadata targets, and secret handling separately.")
    return 0 if all(checks.values()) else 1


if __name__ == "__main__":
    raise SystemExit(main())

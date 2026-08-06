#!/usr/bin/env python3

import sys
from pathlib import Path


def main():
    if len(sys.argv) < 2:
        raise SystemExit(
            "usage: render-prompt.py TEMPLATE [KEY=FILE ...]"
        )

    template = Path(sys.argv[1]).read_text()

    for assignment in sys.argv[2:]:
        key, filename = assignment.split("=", 1)
        value = Path(filename).read_text()
        template = template.replace("{{" + key + "}}", value)

    sys.stdout.write(template)


if __name__ == "__main__":
    main()

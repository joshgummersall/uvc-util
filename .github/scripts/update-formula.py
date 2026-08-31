#!/usr/bin/env python3
"""Point Formula/uvc-util.rb at a released binary.

Usage: update-formula.py <version> <url> <sha256>

Inserts url/version/sha256 after the `homepage` line if they are not there yet,
otherwise rewrites them in place.  Run by .github/workflows/release.yml; safe to
run by hand if the workflow could not push.
"""

import pathlib
import re
import sys

FORMULA = pathlib.Path(__file__).resolve().parents[2] / "Formula" / "uvc-util.rb"


def main(version, url, sha256):
    if not re.fullmatch(r"[0-9a-f]{64}", sha256):
        sys.exit("error: sha256 is not 64 hex digits: %s" % sha256)

    text = FORMULA.read_text()
    fields = {"url": url, "version": version, "sha256": sha256}
    missing = []

    for name, value in fields.items():
        pattern = re.compile(r'^(\s*)%s\s+"[^"]*"$' % name, re.MULTILINE)
        replacement = r'\g<1>%s "%s"' % (name, value)
        text, count = pattern.subn(replacement, text, count=1)
        if count == 0:
            missing.append('  %s "%s"' % (name, value))

    if missing:
        anchor = re.compile(r'^(\s*homepage\s+"[^"]*"\n)', re.MULTILINE)
        if not anchor.search(text):
            sys.exit("error: no homepage line to insert after in %s" % FORMULA)
        text = anchor.sub(r"\g<1>" + "\n".join(missing) + "\n", text, count=1)

    FORMULA.write_text(text)
    print("updated %s to %s" % (FORMULA, version))


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])

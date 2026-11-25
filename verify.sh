#!/usr/bin/env bash
# Verifies a downloaded release: SHA256SUMS for the assets, gzip integrity, and that the
# uncompressed catalog matches the checksum on the first line of SHA256SUMS.
# Usage: ./verify.sh <directory with the downloaded release files>
set -euo pipefail
dir="${1:-.}"
cd "$dir"
[ -f SHA256SUMS ] || { echo "error: SHA256SUMS not found in $dir" >&2; exit 1; }

# Lines after the first cover the compressed assets; the first covers the uncompressed catalog.
tail -n +2 SHA256SUMS | shasum -a 256 -c -

for f in catalog-*.sqlite.gz id-map.tsv.gz; do
  [ -f "$f" ] || { echo "error: $f missing" >&2; exit 1; }
  gzip -t "$f"
  echo "$f: gzip ok"
done

raw_expected="$(head -n1 SHA256SUMS | cut -d' ' -f1)"
for f in catalog-*.sqlite.gz; do
  raw_actual="$(gzip -dc "$f" | shasum -a 256 | cut -d' ' -f1)"
  [ "$raw_actual" = "$raw_expected" ] || { echo "error: uncompressed $f does not match SHA256SUMS" >&2; exit 1; }
  echo "$f: uncompressed sha256 ok"
done
echo "release verified"

# Quality report layout (template)

Each release can attach the build's quality output: `qa-report.md`, `quarantine.tsv` and
`merges.tsv`. All sources are public, so these files hold no personal data.

```
catalog <version>: <N> foods from <M> source rows (<source> <n>, ...)
  filtered: <n> (<reason> <n>, ...)
  quarantined: <n> (<reason> <n>, ...)
  merged: <n> near-duplicates, <n> same barcode; new ids: <n>
  notes: ...
  volume basis (per 100 ml, no grams): <n> foods
  display names: <n> differ from the source name
  reference foods: all match
  size: <MiB> (<MiB> deflate), <n> barcodes, sha256 <hex>
```

- `quarantine.tsv`: `source`, `source_id`, `name`, `reasons` for every row left out by a
  quality check (see METHOD.md section 5).
- `merges.tsv`: `survivor`, `merged`, `kind` (`barcode` or `near-duplicate`).

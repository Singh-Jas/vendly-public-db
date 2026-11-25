# Food database @VERSION@

Built @BUILT_AT@ from the sources pinned in `sources.json`.

| Asset | Description |
|---|---|
| `@ASSET@` | catalog.sqlite, gzip (`gunzip` it) |
| `SHA256SUMS` | sha256 of the uncompressed catalog and of the other assets |
| `id-map.tsv.gz` | stable id map (format: `id-map/FORMAT.md`) |
| `sources.json` | pinned source dumps (url, release, sha256) |
| `qa-report.md`, `quarantine.tsv`, `merges.tsv` | quality output of this build |
| `LICENSE`, `LICENSE-ODbL-1.0.txt`, `LICENSE-MIT`, `NOTICE.md` | licence and attribution |

- catalog.sqlite sha256 (uncompressed): `@SHA_RAW@`
- compressed sha256: `@SHA_GZ@`
- Licence recorded in the file (`meta.license`): @LICENSE_META@

Database under ODbL 1.0. (c) Open Food Facts contributors; USDA FoodData Central is public
domain. See NOTICE.md. How the data is selected and modified: METHOD.md.

# Vendly food database

An open nutrition database of US foods, derived from USDA FoodData Central and Open Food Facts.
This repository holds the documentation, the stable id map and the licence files. The database
itself is published as GitHub Release assets.

- How the source data is selected and modified: [METHOD.md](METHOD.md)
- Pinned source dumps (URL, release, sha256): [sources.json](sources.json)
- Stable id map (`source_db`, `source_id`, `id`): [id-map/](id-map/FORMAT.md)
- Attribution and licence provenance: [NOTICE.md](NOTICE.md)

## Get the database

1. Open the Releases page of this repository:
   https://github.com/Singh-Jas/vendly-public-db/releases
2. Download `catalog-<version>.sqlite.gz`, `SHA256SUMS` and `id-map.tsv.gz` from the release
   tagged `db-<version>`.
3. Verify and unpack:

       ./verify.sh <directory containing the downloaded files>

   `verify.sh` checks every file against `SHA256SUMS` and tests that the gzip files decompress.
   To do it by hand: `shasum -a 256 -c SHA256SUMS` (the first line lists the uncompressed
   catalog; compare it with `shasum -a 256` of the file after `gunzip`).

Each release also attaches `sources.json`, the quality output of the build (`qa-report.md`,
`quarantine.tsv`, `merges.tsv`) and the licence files.

## Licence

| Part | Licence |
|---|---|
| The database (release assets) | Open Database License (ODbL) 1.0, [LICENSE-ODbL-1.0.txt](LICENSE-ODbL-1.0.txt) |
| Open Food Facts contents | Database Contents License (DbCL) 1.0, (c) Open Food Facts contributors |
| USDA FoodData Central data | Public domain (CC0 1.0) |
| Documentation and scripts here | MIT, [LICENSE-MIT](LICENSE-MIT) |

Summary and details: [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md). Nutrition data is
informational and not medical advice. Product images are not included.

## Contact

singhstudioapp@gmail.com

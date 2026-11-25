# Notice and attribution

This database is built from the sources pinned in `sources.json` (names, release dates,
download URLs and sha256 of the exact files used). How the data is selected and changed is
described in `METHOD.md`.

## Open Food Facts

Contains information from Open Food Facts, which is made available under the Open
Database License (ODbL) 1.0.

(c) Open Food Facts contributors. https://world.openfoodfacts.org

- Database: ODbL 1.0, https://opendatacommons.org/licenses/odbl/1-0/
- Individual contents: Database Contents License 1.0,
  https://opendatacommons.org/licenses/dbcl/1-0/
- Product images are licensed separately (CC BY-SA) and are NOT included.
- `sources.json` entry `off` is the rolling daily CSV export; the pinned sha256 identifies the
  copy a release used.

Changes made to Open Food Facts rows: only US products are kept; names and brands are cleaned
for display; nutrients are normalised to per 100 g (or per 100 ml); rows that fail quality
checks are left out (`quarantine.tsv` in each release); duplicates by barcode are merged with
USDA winning. The full list of changes is in `METHOD.md`. The id map is `id-map/id-map.tsv`.

## USDA FoodData Central

Foundation Foods, SR Legacy, FNDDS and Branded Foods from the U.S. Department of
Agriculture, Agricultural Research Service, FoodData Central, https://fdc.nal.usda.gov.
Public domain (CC0 1.0) per the USDA's statement. The USDA does not endorse this database.

## Licence texts

- `LICENSE-ODbL-1.0.txt` is the ODbL 1.0 text as published at
  https://opendatacommons.org/licenses/odbl/1-0/, unmodified. Its sha256 is
  `607680718977f6f6c9607972afd98f208573f19251315ed1362a8589b51beaf5`.
- `LICENSE-MIT` is the standard MIT licence text for the documentation and scripts.

## Contact

Questions, corrections and licence queries: singhstudioapp@gmail.com. Open Food Facts reuse
questions: reuse@openfoodfacts.org.

# Method: how the source data is selected and modified

This document describes, precisely and in plain language, how the published food database
(`catalog.sqlite`, attached to each GitHub Release) is derived from its sources. It is the
description of the changes made to the Open Food Facts database that the ODbL asks for, and it
lets anyone check a release against the pinned sources.

The pipeline code is not published. This document, `sources.json`, `id-map/id-map.tsv` and the
per-release quality files (`qa-report.md`, `quarantine.tsv`, `merges.tsv`) are the record.

## 1. Sources

Pinned in `sources.json` (release date, URL, sha256):

| `source_db` | Source | Format |
|---|---|---|
| `usda_foundation` | USDA FoodData Central, Foundation Foods | JSON |
| `usda_sr` | USDA FoodData Central, SR Legacy | JSON |
| `usda_fndds` | USDA FoodData Central, FNDDS (survey foods) | JSON |
| `usda_branded` | USDA FoodData Central, Branded Foods | JSON |
| `off` | Open Food Facts product export | tab-separated CSV, gzip |

The first four are USDA public-domain data. `off` is the Open Food Facts daily export
(ODbL 1.0 database, DbCL 1.0 contents). Open Food Facts is a rolling export: its URL always
serves the newest file, so the sha256 in `sources.json` identifies the exact copy a release was
built from. Product images are never used.

## 2. Selection filters (applied before quality checks)

Rows that fail a filter are dropped and counted in the release's `qa-report.md`.

**USDA Foundation, SR Legacy, FNDDS:** all foods are read.

**USDA Branded:** a row is dropped if, checked in this order:

1. it has a discontinued date;
2. its barcode (`gtinUpc`) is not a valid GTIN (see section 4);
3. its market country is not the United States (`United States` or `US`);
4. it lacks any of energy, protein, carbohydrate or fat.

**Open Food Facts:** only rows whose `countries_tags` includes `en:united-states` are read.
Then a row is dropped if, in this order:

1. its `code` is not a valid GTIN;
2. its product name, after cleanup, is shorter than 2 characters;
3. it lacks any of energy, protein, carbohydrate or fat;
4. the cut rule below drops it.

**Cut rule for Open Food Facts rows.** A row is kept if it has at least one unique scan on
Open Food Facts (`unique_scans_n >= 1`) or it has a brand. Rows with neither are dropped. The
rule is a build setting; each release's `qa-report.md` shows the counts. Rows already present
from USDA by barcode lose to USDA (section 6).

The columns read from the Open Food Facts export are: `code`, `last_modified_t`,
`product_name`, `brands`, `quantity`, `countries_tags`, `serving_size`, `serving_quantity`,
`unique_scans_n`, `energy-kcal_100g`, `energy-kj_100g`, `energy_100g`, `fat_100g`,
`saturated-fat_100g`, `carbohydrates_100g`, `sugars_100g`, `fiber_100g`, `proteins_100g`,
`salt_100g`, `sodium_100g`, `alcohol_100g`.

## 3. Normalisation

All nutrient values are stored per 100 g (`basis = 'mass'`) or per 100 ml (`basis = 'volume'`).
Energy is kcal, sodium is mg, everything else g (micronutrients as in `nutrient_def`).

**USDA nutrients** are already per 100 g. For each column the first available USDA nutrient
number is used: energy 208, 958, 957 (if none, kJ from 268 divided by 4.184, rounded to 0.1);
protein 203; carbohydrate 205, 205.2; fat 204, 298; alcohol 221; fiber 291; sugars 269, 269.3;
sodium 307; saturated fat 606.

**Open Food Facts nutrients:** energy is `energy-kcal_100g`, else kJ (`energy-kj_100g`, else
`energy_100g`) divided by 4.184, rounded to 0.1. Sodium is `sodium_100g` times 1000, else
`salt_100g` divided by 2.5 times 1000. Other columns map directly.

**Mass or volume.** For Branded, the basis is volume when the label serving unit is ml; for
Open Food Facts, when the serving size or `quantity` text is a volume (ml, cl, dl, l, fl oz).
A volume food keeps per-100 ml values and gets no gram weight: no density is ever assumed or
stored.

**Servings.** Each food gets, in order: the source's own servings, then `100 g` and `1 oz`
(28.349523125 g) for mass foods, or `100 ml` and `1 fl oz` for volume foods. Source servings
are USDA portions (household measure labels, gram weight greater than 0 and less than 2000;
duplicates by normalised label dropped), the Branded label serving with its household text
(with GDSN unit codes such as `ONZ` written as `oz`), or the Open Food Facts
`serving_quantity` with its `serving_size` text. Serving amounts must be above 0 and below 2000
(g or ml). The first source serving is the default; if none, `100 g` (or `100 ml`).

**Micronutrients** (29 nutrients, listed in the `nutrient_def` table, keyed by USDA nutrient
number) are kept for Foundation, SR Legacy and FNDDS foods only. A value whose unit differs
from the expected unit is dropped.

## 4. Barcodes

Barcodes are validated (whitespace and hyphens ignored; EAN-8, UPC-A, EAN-13 or GTIN-14 with a
valid GS1 check digit; compressed UPC-E codes are not expanded) and stored as GTIN-14,
left-padded with zeros. Rows with an invalid code are
filtered. A barcode appears at most once in the database.

## 5. Quality checks (quarantine)

A food that fails any check is left out and listed with its reasons in `quarantine.tsv`.

- Name must not be empty.
- Energy, protein and fat must be present. Carbohydrate may be missing only on USDA Foundation
  foods, where it is then taken as 0 (noted as imputed).
- Small negative values down to -1 are clamped to 0; below -1 fails.
- Energy at most 902 kcal per 100 g; protein, carbohydrate and fat each at most 100 g; their sum
  at most 105 g.
- Energy consistency: with fiber capped at the carbohydrate amount, expected energy is
  `4 x protein + 4 x (carbohydrate - fiber) + 2 x fiber + 9 x fat + 7 x alcohol`. Energy must be
  within 20% of this, or within 10 kcal, whichever is larger. For USDA Foundation, SR Legacy
  and FNDDS foods a mismatch is kept (USDA energy uses food-specific factors) and only noted;
  for Branded and Open Food Facts rows it fails.
- Label serving check (Branded rows that state label calories): label
  calories must be within 10% (or 5 kcal) of the per-100 value scaled to the serving size.
- Open Food Facts rows with a quality failure are not repaired; they are left out.

Each release also checks about 50 reference foods against USDA values exactly.

## 6. Deduplication

Applied after quality checks, in two passes.

1. **Same barcode.** If several rows share a barcode, one survives: the most recent record
   (Branded: publication date, then label modified date; Open Food Facts rows rank below any USDA
   row), then the higher quality score, then the higher source key. Source priority is Foundation,
   SR Legacy, FNDDS, Branded, Open Food Facts.
2. **Near-duplicates.** Foods with the same normalised name (lower-cased, punctuation removed,
   words sorted), the same normalised brand and the same basis, whose energy, protein,
   carbohydrate and fat each differ by at most 2% (or 0.1), are merged. The survivor is the
   higher-priority source, then the lower source id. Foods with no brand (USDA common foods)
   are never merged with branded foods.

The merged food's name is kept as an alias on the survivor; its non-standard servings and its
barcodes move to the survivor (servings only between foods on the same basis). `merges.tsv`
lists every merge.

`quality_score` (0 to 1) is a base by source (Foundation 1.0, SR Legacy 0.9, FNDDS 0.85,
Branded 0.6, Open Food Facts 0.5), minus up to 0.1 for missing optional columns (fiber, sugars,
sodium, saturated fat) and 0.05 if carbohydrate was imputed.

## 7. Name and brand cleanup

The source name is kept as `name`. A cleaned name goes in `display_name` (NULL when identical).

**Source name cleanup** (all sources): whitespace is collapsed. USDA SR Legacy's program note
"(Includes foods for USDA's Food Distribution Program)" is removed. For Branded and Open Food
Facts, comma-separated segments that repeat an earlier segment are dropped, and names written in
all capitals are title-cased (initialisms such as BBQ, USA, UHT stay upper case; small words such
as and, of, with stay lower case).

**Brand:** Branded uses the brand name, else the brand owner; Open Food Facts uses the first
brand listed. Placeholder values (`not a branded item`, `n/a`, `none`, `unbranded`, `no brand`,
`generic`, `unknown`) mean no brand. Brands in all capitals are title-cased.

**Display names**, USDA Foundation, SR Legacy and FNDDS (common foods):

- drop filler segments ("broilers or fryers", "meat only", "NFS", "NS as to ...", "all grades",
  "imported", "ready-to-eat", and similar);
- shorter wording ("separable lean only" becomes "lean only", "meat and skin" becomes "with
  skin");
- one wording per cooking method ("cooked, roasted" becomes "roasted"; "pan fried" becomes
  "pan-fried"; "sauteed" becomes "sautéed"), FNDDS "fat added" becomes "with fat";
- "without salt" becomes "unsalted", "with salt" becomes "salted";
- a leading category word is dropped when the next part names the food ("Nuts, almonds" becomes
  "Almonds"), or moved to the end ("Babyfood" becomes "baby food" last);
- the modifier is put before the noun ("Rice, white" becomes "White rice", "Beef, ground"
  becomes "Ground beef");
- brand names in capitals are title-cased.

**Display names**, Branded and Open Food Facts:

- a leading "Brand, " is dropped when it equals the brand field;
- trailing package sizes and counts ("21 oz.", "4 Count") are dropped;
- a trailing segment whose exact text already appears earlier in the name is dropped.

When two names are the same after rewriting, nothing else is changed. The original name remains
searchable as `name`.

## 8. Stable ids

`food.id` comes from the persisted map in `id-map/id-map.tsv` (format: `id-map/FORMAT.md`).

- Each `(source_db, source_id)` is assigned an integer id once, when it first passes the quality
  checks. The id is never changed or reused, even if the food later leaves the database.
- Every food that reaches the quality step gets an id, merged foods included.
- New ids are assigned above the current maximum, in source priority order and then source-id
  order, so assignment depends only on the set of inputs.
- A merged food keeps its own row in the map; the survivor's id is what appears in the database.

A release's `new ids` count in `qa-report.md` is the number of rows appended to the map.

## 9. Reproducibility

Given the pinned inputs, the id map and the same settings, the build is deterministic: foods are
inserted in id order with a fixed page size (4096), journal mode DELETE, full-text index rebuilt
and optimised, `ANALYZE` and `VACUUM`, and `meta.built_at` set to the newest source release date.
Two builds are compared and must be byte-identical before a release is made. The sha256 of the
uncompressed database and of every asset is in `SHA256SUMS`.

Because the Open Food Facts export is rolling, only the pinned copy (identified by sha256) can
reproduce a release; newer exports produce a different database and new ids.

## 10. Published schema

The release asset is a SQLite database. Tables:

**`food`**: `id` (integer primary key), `source_db`, `source_id` (unique together), `name`,
`display_name`, `brand`, `category`, `aliases` (alternate names from merges), `kcal100`,
`protein100`, `carb100`, `fat100` (required), `fiber100`, `sugar100`, `sodium100` (mg),
`sat_fat100` (nullable), `basis` (`mass` or `volume`), `is_common` (1 for USDA Foundation, SR
Legacy, FNDDS), `quality_score`, `popularity` (currently 0), `search_rank` (an ordering helper
derived from `is_common`, `popularity`, `quality_score`, `id`).

**`serving`**: `food_id`, `label`, `grams` (above 0, below 2000), `is_default`, `source`
(`standard` for 100 g and 1 oz, otherwise the `source_db`). Mass foods only.

**`serving_ml`**: same as `serving` with `ml`. Volume foods only.

**`barcode`**: `code` (GTIN-14, primary key), `food_id`.

**`nutrient_def`**: `nutrient_id` (USDA nutrient number), `name`, `unit`, `dv_amount` (FDA Daily
Value for adults and children 4 years and older, where one exists).

**`micronutrient`**: `food_id`, `nutrient_id`, `amount100` (common foods only).

**`food_fts`**: an FTS5 full-text index over `name`, `brand`, `aliases`, `display_name`
(`unicode61 remove_diacritics 2`, prefixes of 2 and 3 characters), keyed by `search_rank`.

**`meta`**: `version`, `schema` (schema version, currently 4), `built_at`, `sources` (the pinned
sources as JSON), `license` (the attribution text).

## 11. Contact

singhstudioapp@gmail.com

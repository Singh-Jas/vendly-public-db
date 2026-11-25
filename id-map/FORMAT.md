# id-map.tsv

Persisted map `(source_db, source_id) -> id`. It keeps `food.id` stable across database
releases. Every release also attaches the file as `id-map.tsv.gz`.

Format: UTF-8, LF line endings, tab-separated, one header line:

    source_db<TAB>source_id<TAB>id

- `source_db`: `usda_foundation`, `usda_sr`, `usda_fndds`, `usda_branded` or `off`.
- `source_id`: the id in that source (USDA FDC id, or the Open Food Facts product code).
- `id`: positive integer, unique across the file, never reused or changed. A food that leaves
  the database keeps its row.
- Rows are sorted by `id`; new ids go above the current maximum, so a diff only appends.
- Merged records keep the survivor's id; the merged records keep their own rows too.

The file holds only source keys and ids.

CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_19_race` AS (

WITH
  crosswalk AS (
    SELECT uniqueprecinctcode, pctnum
    FROM
      `prod-organize-arizon-4e1c0a83.rich_christina_proj.catalist_pctnum_crosswalk_native`
  ),
  race AS (
    SELECT d.uniqueprecinctcode, m.race, COUNT(p.dwid) AS race_counts
    FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p
    JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
      ON p.dwid = d.dwid
    LEFT JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__models` AS m
      ON p.dwid = m.dwid
    WHERE
      d.state = 'AZ'
      AND p.state = 'AZ'
      AND d.statehousedistrict = '19'
      AND voterstatus = 'active'
      AND m.race IS NOT NULL
    GROUP BY 1, 2
  )
SELECT
  p.COUNTY AS county,
  INITCAP(p.PRECINCTNA) AS precinct_name,
  r.race,
  r.race_counts
FROM race AS r
INNER JOIN
  crosswalk AS cw  
  ON r.uniqueprecinctcode = cw.uniqueprecinctcode
LEFT JOIN `prod-organize-arizon-4e1c0a83.geofiles.az_precincts_geo` AS p
  ON cw.pctnum = p.PCTNUM
)

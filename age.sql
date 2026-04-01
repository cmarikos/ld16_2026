CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_16_age` AS (

WITH
  crosswalk AS (
    SELECT uniqueprecinctcode, pctnum
    FROM
      `prod-organize-arizon-4e1c0a83.rich_christina_proj.catalist_pctnum_crosswalk_native`
  ),
  age AS (
    SELECT d.uniqueprecinctcode
    , m.catalistmodel_age_bin_4_0
    , COUNT(p.dwid) AS age_counts
    FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p
    JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
      ON p.dwid = d.dwid
    LEFT JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__models` AS m
      ON p.dwid = m.dwid
    WHERE
      d.state = 'AZ'
      AND p.state = 'AZ'
      AND d.statehousedistrict = '16'
      AND voterstatus = 'active'
      AND m.catalistmodel_age_bin_4_0 IS NOT NULL
    GROUP BY 1, 2
  )
SELECT
  p.COUNTY AS county
  , INITCAP(p.PRECINCTNA) AS precinct_name
  , a.catalistmodel_age_bin_4_0
  , a.age_counts
FROM age AS a
INNER JOIN
  crosswalk AS cw  
  ON a.uniqueprecinctcode = cw.uniqueprecinctcode
LEFT JOIN `prod-organize-arizon-4e1c0a83.geofiles.az_precincts_geo` AS p
  ON cw.pctnum = p.PCTNUM
)
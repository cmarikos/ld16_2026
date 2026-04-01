CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_16_vch` AS (

WITH
  crosswalk AS (
    SELECT uniqueprecinctcode, pctnum
    FROM
      `prod-organize-arizon-4e1c0a83.rich_christina_proj.catalist_pctnum_crosswalk_native`
  ),
  vch AS (
    SELECT d.uniqueprecinctcode
    , CASE
        WHEN CAST(m.catalistmodel_vch_index_2024 AS FLOAT64) <= 30 THEN "0-30"
        WHEN  (CAST(m.catalistmodel_vch_index_2024 AS FLOAT64) > 30 
          AND  CAST(m.catalistmodel_vch_index_2024 AS FLOAT64) < 70) THEN "30-70"
        WHEN  CAST(m.catalistmodel_vch_index_2024 AS FLOAT64) >= 70 THEN "70-100"
        ELSE NULL
      END AS vch_bin
    , COUNT(p.dwid) AS vch_counts
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
      AND m.catalistmodel_vch_index_2024 IS NOT NULL
    GROUP BY 1, 2
  )
SELECT
  p.COUNTY AS county
  , INITCAP(p.PRECINCTNA) AS precinct_name
  , v.vch_bin
  , v.vch_counts
FROM vch AS v
INNER JOIN
  crosswalk AS cw  
  ON v.uniqueprecinctcode = cw.uniqueprecinctcode
LEFT JOIN `prod-organize-arizon-4e1c0a83.geofiles.az_precincts_geo` AS p
  ON cw.pctnum = p.PCTNUM
)
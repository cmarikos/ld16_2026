CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_19_voteprop` AS (

WITH
  crosswalk AS (
    SELECT uniqueprecinctcode, pctnum
    FROM
      `prod-organize-arizon-4e1c0a83.rich_christina_proj.catalist_pctnum_crosswalk_native`
  ),
  voteprop AS (
    SELECT d.uniqueprecinctcode
    , CASE
        WHEN m.catalistmodel_voteprop2026 <= 30 THEN "0-30"
        WHEN  (m.catalistmodel_voteprop2026 > 30 
          AND  m.catalistmodel_voteprop2026 < 70) THEN "30-70"
        WHEN  m.catalistmodel_voteprop2026 >= 70 THEN "70-100"
        ELSE NULL
      END AS voteprop_bin
    , COUNT(p.dwid) AS voteprop_counts
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
      AND m.catalistmodel_voteprop2026 IS NOT NULL
    GROUP BY 1, 2
  )
SELECT
  p.COUNTY AS county
  , INITCAP(p.PRECINCTNA) AS precinct_name
  , v.voteprop_bin
  , v.voteprop_counts
FROM voteprop AS v
INNER JOIN
  crosswalk AS cw  
  ON v.uniqueprecinctcode = cw.uniqueprecinctcode
LEFT JOIN `prod-organize-arizon-4e1c0a83.geofiles.az_precincts_geo` AS p
  ON cw.pctnum = p.PCTNUM
)
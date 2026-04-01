CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_16_gender` AS (

WITH
  crosswalk AS (
    SELECT uniqueprecinctcode, pctnum
    FROM
      `prod-organize-arizon-4e1c0a83.rich_christina_proj.catalist_pctnum_crosswalk_native`
  ),
  gender AS (
    SELECT d.uniqueprecinctcode
    , p.gender
    , COUNT(p.dwid) AS gender_counts
    FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p
    JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
      ON p.dwid = d.dwid
    WHERE
      d.state = 'AZ'
      AND p.state = 'AZ'
      AND d.statehousedistrict = '16'
      AND voterstatus = 'active'
      AND p.gender <> 'unspecified'
    
    GROUP BY 1, 2
  )
SELECT
  p.COUNTY AS county
  , INITCAP(p.PRECINCTNA) AS precinct_na
  , g.gender
  , g.gender_counts
FROM gender AS g
INNER JOIN
  crosswalk AS cw  
  ON g.uniqueprecinctcode = cw.uniqueprecinctcode
LEFT JOIN `prod-organize-arizon-4e1c0a83.geofiles.az_precincts_geo` AS p
  ON cw.pctnum = p.PCTNUM
)
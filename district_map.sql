CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_16_2026_map` AS (

WITH crosswalk AS (
  SELECT
    uniqueprecinctcode,
    pctnum
  FROM `prod-organize-arizon-4e1c0a83.rich_christina_proj.catalist_pctnum_crosswalk_native`
),

dem_voters AS(
  SELECT
  d.uniqueprecinctcode
  , COUNT(DISTINCT p.dwid) AS dem_count

  FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p

  INNER JOIN  `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
   ON p.dwid = d.dwid

  WHERE d.state = 'AZ'
  AND p.state = 'AZ'
  AND p.voterstatus = 'active'
  AND d.statehousedistrict = '16'
  AND partyaffiliation = 'DEM'

  GROUP BY 1
)

, all_voters AS(
  SELECT
  d.uniqueprecinctcode
  , COUNT(DISTINCT p.dwid) AS reg_count

  FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p

  INNER JOIN  `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
   ON p.dwid = d.dwid

  WHERE d.state = 'AZ'
  AND p.state = 'AZ'
  AND p.voterstatus = 'active'
  AND d.statehousedistrict = '16'
  

  GROUP BY 1
)


SELECT 
p.COUNTY AS county
,INITCAP(p.PRECINCTNA) AS precinct_name
, SAFE_DIVIDE(d.dem_count,a.reg_count) AS dem_pct
,d.dem_count
,a.reg_count
, p.GEOMETRY


FROM all_voters AS a

LEFT JOIN dem_voters AS d
  ON a.uniqueprecinctcode = d.uniqueprecinctcode

LEFT JOIN crosswalk AS cw
 ON d.uniqueprecinctcode = cw.uniqueprecinctcode
 
LEFT JOIN `prod-organize-arizon-4e1c0a83.geofiles.az_precincts_geo` AS p
  ON cw.pctnum = p.PCTNUM 
  
WHERE cw.pctnum IS NOT NULL                
) 
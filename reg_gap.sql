CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_16_cvap_map` AS (

WITH crosswalk AS (
  SELECT
    uniqueprecinctcode,
    pctnum
  FROM `prod-organize-arizon-4e1c0a83.rich_christina_proj.catalist_pctnum_crosswalk_native`
)

, cvap AS(
SELECT
  d.uniqueprecinctcode
  , COUNT(DISTINCT p.dwid) AS cvap_count

  FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p

  INNER JOIN  `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
   ON p.dwid = d.dwid

  WHERE d.state = 'AZ'
  AND p.state = 'AZ'
  AND d.statehousedistrict = '16'
  AND p.nextelectiondayage >= 18
  AND p.deceased = 'N'
  AND p.voterstatusreason IS NULL

  GROUP BY 1
)

, voters AS(
SELECT
  d.uniqueprecinctcode
  , COUNT(DISTINCT p.dwid) AS voter_count

  FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p

  INNER JOIN  `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
   ON p.dwid = d.dwid

  WHERE d.state = 'AZ'
  AND p.state = 'AZ'
  AND d.statehousedistrict = '16'
  AND voterstatus ='active'

  GROUP BY 1
)

SELECT
p.COUNTY AS county
,INITCAP(p.PRECINCTNA) AS precinct_name
, SAFE_DIVIDE(v.voter_count, c.cvap_count) AS reg_percent

FROM cvap AS c

LEFT JOIN voters AS v
  ON c.uniqueprecinctcode = v.uniqueprecinctcode
  
LEFT JOIN crosswalk AS cw
 ON c.uniqueprecinctcode = cw.uniqueprecinctcode
 
LEFT JOIN `prod-organize-arizon-4e1c0a83.geofiles.az_precincts_geo` AS p
  ON cw.pctnum = p.PCTNUM 
  
WHERE cw.pctnum IS NOT NULL  

ORDER BY 3 
)

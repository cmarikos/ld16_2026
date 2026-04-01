CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_16_aevl_slices_by_precinct` AS
WITH crosswalk AS (
  SELECT
    uniqueprecinctcode,
    pctnum
  FROM `prod-organize-arizon-4e1c0a83.rich_christina_proj.catalist_pctnum_crosswalk_native`
),

aevl AS (
  SELECT
    d.uniqueprecinctcode,
    COUNT(DISTINCT p.dwid) AS aevl_count
  FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p
  JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
    ON p.dwid = d.dwid
  WHERE d.state = 'AZ'
    AND p.state = 'AZ'
    AND d.statehousedistrict = '16'
    AND p.voterstatus = 'active'
    AND p.permanentabsenteevoter = 'Y'
  GROUP BY 1
),

voters AS (
  SELECT
    d.uniqueprecinctcode,
    COUNT(DISTINCT p.dwid) AS voter_count
  FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p
  JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
    ON p.dwid = d.dwid
  WHERE d.state = 'AZ'
    AND p.state = 'AZ'
    AND d.statehousedistrict = '16'
    AND p.voterstatus = 'active'
  GROUP BY 1
),

base AS (
  SELECT
    pgeo.COUNTY AS county,
    INITCAP(pgeo.PRECINCTNA) AS precinct_name,
    v.uniqueprecinctcode,
    v.voter_count,
    COALESCE(a.aevl_count, 0) AS aevl_count
  FROM voters v
  LEFT JOIN aevl a
    ON v.uniqueprecinctcode = a.uniqueprecinctcode
  LEFT JOIN crosswalk cw
    ON v.uniqueprecinctcode = cw.uniqueprecinctcode
  LEFT JOIN `prod-organize-arizon-4e1c0a83.geofiles.az_precincts_geo` AS pgeo
    ON cw.pctnum = pgeo.PCTNUM
  WHERE cw.pctnum IS NOT NULL
)

-- TWO ROWS PER PRECINCT: AEVL + Not AEVL
SELECT
  county,
  precinct_name,
  uniqueprecinctcode,
  'AEVL' AS slice,
  aevl_count AS votes
FROM base

UNION ALL

SELECT
  county,
  precinct_name,
  uniqueprecinctcode,
  'Not AEVL' AS slice,
  (voter_count - aevl_count) AS votes
FROM base


-- there is a much better way to do this, robots is dumb
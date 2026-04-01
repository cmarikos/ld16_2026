CREATE OR REPLACE VIEW `prod-organize-arizon-4e1c0a83.rich_christina_proj.ld_16_aevl_pie` AS(
WITH aevl AS (
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
    v.uniqueprecinctcode,
    v.voter_count,
    COALESCE(a.aevl_count, 0) AS aevl_count
  FROM voters v
  LEFT JOIN aevl a
    ON v.uniqueprecinctcode = a.uniqueprecinctcode
)
SELECT
  slice,
  votes
FROM (
  SELECT 'AEVL' AS slice, SUM(aevl_count) AS votes FROM base
  UNION ALL
  SELECT 'Not AEVL' AS slice, SUM(voter_count - aevl_count) AS votes FROM base
)
)
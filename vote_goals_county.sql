WITH rv AS (

SELECT DISTINCT	
d.countyname
,CASE
    WHEN p.partyaffiliation = 'DEM' THEN 'DEM'
    WHEN p.partyaffiliation = 'REP' THEN 'GOP'
    ELSE '3RD' 
  END AS party
, COUNT(DISTINCT p.dwid) AS RV

FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p

INNER JOIN  `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
  ON p.dwid = d.dwid

WHERE d.state = 'AZ'
AND p.state = 'AZ'
AND p.voterstatus = 'active'
AND d.statehousedistrict = '19'

GROUP BY 1,2
ORDER BY 1 
)

, lv AS(

SELECT DISTINCT	
d.countyname
,CASE
    WHEN p.partyaffiliation = 'DEM' THEN 'DEM'
    WHEN p.partyaffiliation = 'REP' THEN 'GOP'
    ELSE '3RD' 
  END AS party
, COUNT(DISTINCT p.dwid) AS LV

FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p

INNER JOIN  `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
  ON p.dwid = d.dwid

LEFT JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__models` AS m
  ON d.dwid = m.dwid

WHERE d.state = 'AZ'
AND p.state = 'AZ'
AND p.voterstatus = 'active'
AND d.statehousedistrict = '19'
AND m.catalistmodel_voteprop2026 >= 70

GROUP BY 1,2
ORDER BY 1 
)
 
SELECT DISTINCT
r.countyname
, r.party
, r.rv
, l.lv
FROM rv AS r

LEFT JOIN lv AS l
  ON r.party = l.party
  AND r.countyname = l.countyname

ORDER BY 1,2


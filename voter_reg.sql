SELECT DISTINCT	
COUNT(p.dwid)
--, m.catalistmodel_ideology_plus

FROM `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__person` AS p

INNER JOIN  `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__district` AS d
  ON p.dwid = d.dwid

LEFT JOIN `proj-tmc-mem-mvp.catalist_cleaned.cln_catalist__models` AS m
  ON d.dwid = m.dwid

WHERE d.state = 'AZ'
AND p.state = 'AZ'
AND d.statehousedistrict = '19'

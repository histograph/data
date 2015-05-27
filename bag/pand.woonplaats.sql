SELECT
  p.identificatie AS id,
  bouwjaar::int,
  ST_AsGeoJSON(ST_Transform(ST_Force_2d(p.geovlak), 4326)) AS geometry
FROM
  pandactueelbestaand p
JOIN
  verblijfsobjectpand vbop
ON
  vbop.gerelateerdpand = p.identificatie
JOIN
  verblijfsobjectactueelbestaand vbo
ON
  vbo.identificatie = vbop.identificatie
JOIN
  nummeraanduidingactueelbestaand na
ON
  na.identificatie = vbo.hoofdadres
JOIN
  openbareruimteactueelbestaand opr
ON
  na.gerelateerdeopenbareruimte = opr.identificatie
WHERE
  opr.gerelateerdewoonplaats = {woonplaatscode}
SELECT
  na.identificatie::bigint AS id,
  (
    SELECT
    array_to_string(array_agg(p.identificatie::bigint), ',') AS pand_ids
    FROM pandactueelbestaand p
    JOIN verblijfsobjectpandactueel vbop
    ON p.identificatie = vbop.gerelateerdpand
    WHERE vbop.identificatie = vbo.identificatie
  ),
  openbareruimtenaam,
  huisnummer,
  huisletter,
  huisnummertoevoeging,
  postcode,
  opr.identificatie AS openbareruimte,
  ST_AsGeoJSON(ST_Transform(ST_Force_2d(geopunt), 4326)) AS geometry
FROM
  nummeraanduidingactueelbestaand na
JOIN
  verblijfsobjectactueelbestaand vbo
ON
  na.identificatie = vbo.hoofdadres
JOIN
  openbareruimte opr
ON
  na.gerelateerdeopenbareruimte = opr.identificatie

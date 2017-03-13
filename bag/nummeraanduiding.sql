SELECT
  na.identificatie::bigint AS id,
  (
    SELECT
    array_to_string(array_agg(p.identificatie::bigint), ',') AS pand_ids
    FROM bagactueel.pand p
    JOIN bagactueel.verblijfsobjectpand vbop
    ON p.identificatie = vbop.gerelateerdpand
    WHERE vbop.identificatie = vbo.identificatie
  ),
  openbareruimtenaam,
  huisnummer,
  huisletter,
  huisnummertoevoeging,
  postcode,
  opr.identificatie AS openbareruimte,
  ST_AsGeoJSON(ST_Transform(ST_Force2D(geopunt), 4326)) AS geometry
FROM
  bagactueel.nummeraanduiding na
JOIN
  bagactueel.verblijfsobject vbo
ON
  na.identificatie = vbo.hoofdadres
JOIN
  bagactueel.openbareruimte opr
ON
  na.gerelateerdeopenbareruimte = opr.identificatie

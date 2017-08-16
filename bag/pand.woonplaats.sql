SELECT * FROM (
  SELECT
    p.identificatie AS id,
    bouwjaar,
    ST_AsGeoJSON(ST_Transform(ST_MakeValid(ST_Force2D(p.geovlak)), 4326)) AS geometry,
    array_to_string(ARRAY(
      SELECT DISTINCT opr.identificatie::bigint FROM
        bagactueel.verblijfsobjectpand vbop
      JOIN
        bagactueel.verblijfsobject vbo
      ON
        vbo.identificatie = vbop.identificatie
      JOIN
        bagactueel.nummeraanduiding na
      ON
        na.identificatie = vbo.hoofdadres
      JOIN
        bagactueel.openbareruimte opr
      ON
        na.gerelateerdeopenbareruimte = opr.identificatie
      WHERE
       vbop.gerelateerdpand = p.identificatie
     ), ',') AS openbareruimtes
  FROM bagactueel.pand p
  JOIN
    bagactueel.verblijfsobjectpand vbop
  ON
    vbop.gerelateerdpand = p.identificatie
  JOIN
    bagactueel.verblijfsobject vbo
  ON
    vbo.identificatie = vbop.identificatie
  JOIN
    bagactueel.nummeraanduiding na
  ON
    na.identificatie = vbo.hoofdadres
  JOIN
    bagactueel.openbareruimte opr
  ON
    na.gerelateerdeopenbareruimte = opr.identificatie
  WHERE
    opr.gerelateerdewoonplaats = {woonplaatscode}
) AS panden
WHERE openbareruimtes != ''

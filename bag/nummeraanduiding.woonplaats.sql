SELECT DISTINCT ON (na.identificatie) /* this is needed since verblijfsobjectgebruiksdoel 
                                      has more records with different verblijfsobjectstatus */
  na.identificatie AS id,
  (
  	SELECT
  	array_to_string(array_agg(p.identificatie), ',') AS pand_ids
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
  ST_AsGeoJSON(ST_Transform(ST_MakeValid(ST_Force2D(geopunt)), 4326)) AS geometry
FROM
  bagactueel.verblijfsobject vbo
JOIN
  bagactueel.verblijfsobjectgebruiksdoel gd
ON
  gd.identificatie = vbo.identificatie
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
AND
  na.aanduidingrecordinactief = FALSE AND 
  vbo.aanduidingrecordinactief = FALSE AND 
  opr.aanduidingrecordinactief = FALSE AND 
  gd.aanduidingrecordinactief = FALSE AND 
  na.einddatumtijdvakgeldigheid IS NULL AND 
  vbo.einddatumtijdvakgeldigheid IS NULL AND 
  opr.einddatumtijdvakgeldigheid IS NULL AND
  gd.einddatumtijdvakgeldigheid IS NULL


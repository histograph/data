SELECT
  identificatie AS id,
  woonplaatsnaam AS name,
  gemeentecode,
  ST_AsGeoJSON(ST_Transform(ST_MakeValid(ST_Force2D(geovlak)), 4326)) AS geometry
FROM
  bagactueel.woonplaats wp
JOIN
  bagactueel.gemeente_woonplaats gwp
ON
  wp.identificatie = gwp.woonplaatscode
WHERE
		wp.aanduidingrecordinactief = FALSE AND 
		wp.einddatumtijdvakgeldigheid IS NULL AND 
    gwp.einddatumtijdvakgeldigheid IS NULL

SELECT
  identificatie::int AS id,
  woonplaatsnaam::text AS name,
  gemeentecode::int,
  ST_AsGeoJSON(ST_Transform(ST_MakeValid(ST_Force2D(geovlak)), 4326)) AS geometry
FROM
  bagactueel.woonplaats wp
JOIN
  bagactueel.gemeente_woonplaats gwp
ON
  wp.identificatie = gwp.woonplaatscode

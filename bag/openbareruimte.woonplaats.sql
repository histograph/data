SELECT
  opr.identificatie AS id,
  openbareruimtenaam AS name,
  gerelateerdewoonplaats::int AS woonplaatscode,
  wp.woonplaatsnaam::text
FROM
  bagactueel.openbareruimte opr
JOIN
  bagactueel.woonplaats wp ON opr.gerelateerdewoonplaats = wp.identificatie
WHERE
  wp.identificatie = {woonplaatscode} AND
  opr.openbareruimtetype = 'Weg'

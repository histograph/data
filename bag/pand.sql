SELECT * FROM (
  SELECT
    p.identificatie AS id,
    bouwjaar,
    ST_AsGeoJSON(ST_Transform(ST_MakeValid(ST_Force2D(p.geovlak)), 4326)) AS geometry,
    array_to_string(ARRAY(
      SELECT DISTINCT opr.identificatie FROM
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
       AND
         na.aanduidingrecordinactief = FALSE AND 
         vbo.aanduidingrecordinactief = FALSE AND 
         opr.aanduidingrecordinactief = FALSE AND 
         vbop.aanduidingrecordinactief = FALSE AND 
         na.einddatumtijdvakgeldigheid IS NULL AND 
         vbo.einddatumtijdvakgeldigheid IS NULL AND 
         opr.einddatumtijdvakgeldigheid IS NULL AND 
         vbop.einddatumtijdvakgeldigheid IS NULL AND
         vbop.verblijfsobjectstatus != 'Verblijfsobject ingetrokken'

     ), ',') AS openbareruimtes
  FROM bagactueel.pand p
  WHERE p.aanduidingrecordinactief = FALSE AND 
        p.einddatumtijdvakgeldigheid IS NULL  

) AS panden
WHERE openbareruimtes != ''

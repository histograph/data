var urlify = require('urlify').create({
  addEToUmlauts: true,
  szToSs: true,
  toLower: true,
  spaces: '-',
  nonPrintable: '-',
  trim: true
});

const commonPrefixLOD = 'https://bag.basisregistraties.overheid.nl/bag/id/';

const prefixesLOD = {
    openbareruimte: commonPrefixLOD + 'openbare-ruimte/',
    woonplaats: commonPrefixLOD + 'woonplaats/',
    pand: commonPrefixLOD + 'pand/',
    nummeraanduiding: commonPrefixLOD + 'nummeraanduiding/'
};

function padID(id){
  return String(id).padStart(16,'0');
}

module.exports = [
  {
    name: 'openbareruimte',
    rowToPitsAndRelations: function(row) {
      var pit = {
        uri: prefixesLOD.openbareruimte + padID(row.id),
        name: row.name,
        type: 'hg:Street',
        data: {
          woonplaatscode: prefixesLOD.woonplaats + row.woonplaatscode,
          woonplaatsnaam: row.woonplaatsnaam
        }
      };

      var woonplaatsRelation = {
        from: pit.uri,
        to: prefixesLOD.woonplaats + row.woonplaatscode,
        type: 'hg:liesIn'
      };

      var nwbId = 'nwb/' + urlify(row.woonplaatsnaam + '-' + row.name);

      var nwbRelation = {
        from: pit.uri,
        to: nwbId,
        type: 'hg:sameHgConcept'
      };

      return [
        {
          type: 'pits',
          obj: pit
        },
        {
          type: 'relations',
          obj: woonplaatsRelation
        },
        {
          type: 'relations',
          obj: nwbRelation
        }
      ];
    }
  },

  {
    name: 'woonplaats',
    rowToPitsAndRelations: function(row) {
      var pit = {
        uri: prefixesLOD.woonplaats + row.id, // note no padding here
        name: row.name,
        type: 'hg:Place',
        geometry: JSON.parse(row.geometry),
        data: {
          gemeentecode: parseInt(row.gemeentecode)
        }
      };

      return [
        {
          type: 'pits',
          obj: pit
        }
      ];
    }
  },

  {
    name: 'pand',
    rowToPitsAndRelations: function(row) {
      var pit = {
        uri: prefixesLOD.pand + padID(row.id),
        type: 'hg:Building',
        validSince: row.bouwjaar,
        geometry: JSON.parse(row.geometry)
      };

      var result = [
        {
          type: 'pits',
          obj: pit
        }
      ];

      if (row.openbareruimtes) {
        row.openbareruimtes.split(',').forEach(function(openbareruimte) {
          result.push({
            type: 'relations',
            obj: {
              from: pit.uri,
              to: prefixesLOD.openbareruimte + padID(openbareruimte),
              type: 'hg:liesIn'
            }
          });
        });
      }

      return result;
    }
  },

  {
    name: 'nummeraanduiding',
    rowToPitsAndRelations: function(row) {
      var pit = {
        uri: prefixesLOD.nummeraanduiding + padID(row.id),
        name: [row.openbareruimtenaam, row.huisnummer, row.huisletter, row.huisnummertoevoeging].filter(function(p) {
            return p;
          }).join(' '),
        type: 'hg:Address',
        geometry: JSON.parse(row.geometry),
        data: {
          openbareruimte: prefixesLOD.openbareruimte + padID(row.openbareruimte),
          postcode: row.postcode
        }
      };

      var relation = {
        from: pit.uri,
        to: prefixesLOD.openbareruimte + padID(row.openbareruimte),
        type: 'hg:liesIn'
      };

      var result = [
        {
          type: 'pits',
          obj: pit
        },
        {
          type: 'relations',
          obj: relation
        }
      ];

      if (row.pand_ids) {
        row.pand_ids.split(',').forEach(function(pandId) {
          result.push({
            type: 'relations',
            obj: {
              from: pit.uri,
              to: prefixesLOD.pand + padID(pandId),
              type: 'hg:liesIn'
            }
          });
        });
      }

      return result;
    }
  }
];

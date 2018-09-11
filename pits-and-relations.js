const fs = require('fs');
const path = require('path');
const schemas = require('histograph-schemas');
const geojsonhint = require('@mapbox/geojsonhint');
const validator = require('is-my-json-valid');
const log = require('histograph-logging');

const my_log = new log("data");

var validators = {
  pits: validator(schemas.pits),
  relations: validator(schemas.relations)
};

function createWriteStream(type, config) {
  return fs.createWriteStream(path.join(config.dataset, config.dataset + '.' + type + '.ndjson'), {
    flags: config.truncate === false ? 'r+' : 'w',
    encoding: 'utf8',
  });
}

module.exports = function(config) {

  var streams = {
    pits: createWriteStream('pits', config),
    relations: createWriteStream('relations', config)
  };

  this.emit = function(type, obj, callback) {
    var jsonValid = validators[type](obj);
    var valid = true;
    var errors;

    if (!jsonValid) {
      errors = validators[type].errors;
      my_log.error("Error validating type: " + type + ", object: " + JSON.stringify(obj) + ", error: " + JSON.stringify(errors));
      valid = false;
    } else if (type === 'pits' && obj.geometry) {
      var geojsonErrors = geojsonhint.hint(obj.geometry);
      if (geojsonErrors.length > 0) {
        errors = geojsonErrors;
        my_log.error("Error validating pit geometry: " + JSON.stringify(obj.geometry) + ", error: " + JSON.stringify(errors));
        valid = false;
      }
    }

    if (!valid) {
      setImmediate(callback, errors);
    } else {
      streams[type].write(JSON.stringify(obj) + '\n', function(err) {
        callback(err);
      });
    }
  };

  this.close = function() {
    streams.pits.close();
    streams.relations.close();
  };

  return this;
};

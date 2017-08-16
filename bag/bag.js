const fs = require('fs');
const util = require('util');
const pg = require('pg');
const path = require('path');
const Cursor = require('pg-cursor');
const async = require('async');
const queries = require('./queries');

const log = require('histograph-logging');

const my_log = new log("data");


var pitsAndRelations;

const woonplaats = null;

// Set woonplaats to a specific BAG woonplaats (name + code)
// to only process one single woonplaats
// Examples:
// var woonplaats = {
//   name: 'de-rijp',
//   code: '3553'
// };
// var woonplaats = {
//   name: 'leiden',
//   code: '2088'
// };
// var woonplaats = {
//   name: 'bussum',
//   code: '1331'
// };
// var woonplaats = {
//   name: 'utrecht',
//   code: '3295'
// };

function runAllQueries(client, callback) {
  async.eachSeries(queries, function(query, callback) {
    var filename = query.name;
    my_log.info("Processing query: " + query.name);
    
    if (woonplaats) {
      filename += '.woonplaats';
    }

    filename += '.sql';

    var sql = fs.readFileSync(path.join(__dirname, filename), 'utf8');
    if (woonplaats) {
      sql = sql.replace('{woonplaatscode}', woonplaats.code);
    }

    runQuery(client, sql, query.name, query.rowToPitsAndRelations, function(err) {
      if(err){
        my_log.error("Error from run query: " + JSON.stringify(err));
      }
      callback(err);
    });
  },

  function(err) {
    if(err){
      my_log.error("Error processing queries: " + JSON.stringify(err));
    }
    callback(err);
  });
}

function runQuery(client, sql, name, rowToPitsAndRelations, callback) {
  var cursor = client.query(new Cursor(sql));
  var cursorSize = 500;
  var count = 0;

  var finished = false;
  async.whilst(function() {
    return !finished;
  },

  function(callback) {

    cursor.read(cursorSize, function(err, rows) {
      if (err) {
        my_log.error("Error in reading cursor: " + JSON.stringify(err));
        callback(err);
      } else {
        if (!rows.length) {
          finished = true;
          callback();
        } else {

          async.eachSeries(rows, function(row, callback) {
            var emit = rowToPitsAndRelations(row);

            async.eachSeries(emit, function(item, callback) {
              pitsAndRelations.emit(item.type, item.obj, function(err) {
                if(err){
                  my_log.error("pitsAndRelations.emit error: " + JSON.stringify(err));
                }
                callback(err);
              });
            },

            function(err) {
              if(err){
                my_log.error("Error processing rows: " + JSON.stringify(err));
              }
              callback(err);
            });
          },

          function(err) {
            count += 1;

            // TODO: create logging function in index.js
            // TODO: use logger from index.js
            my_log.debug(util.format('%d: processed %d rows of %s (%d done)...', count, cursorSize, name, cursorSize * count));
            if(err){
              my_log.error("Error at the end of row processing: " + JSON.stringify(err));
            }
            callback(err);
          });
        }
      }
    });
  },

  function(err) {
    if(err){
      my_log.error("Error waiting for finished: " + JSON.stringify(err));
    }
    callback(err);
  });
}

exports.convert = function(config, callback) {

  pitsAndRelations = require('../pits-and-relations')({
    dataset: 'bag',
    truncate: true
  });
  
  const pool = new pg.Pool(config.db);

  pool.connect(function(err, client, done) {
    if (err) {
      my_log.error("Error connecting to database: " + JSON.stringify(err));
      callback(err);
    } else {
      runAllQueries(client, function(err) {
        done();
        client.end();
        if (err) {
          my_log.error("Error running queries: " + JSON.stringify(err));
        }
        callback(err);
      });
    }
  });
  
  pool.end(function (){});
  
};

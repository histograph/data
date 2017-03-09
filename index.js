var path = require('path');
var async = require('async');
var config = require('histograph-config');
var parseArgs = require('minimist');
require('colors');

var steps = [
  'download',
  'convert',
  'done'
];

var argv = parseArgs(process.argv.slice(2));

// By default, import all datasets with have data config in configuration file
var datasets = Object.keys(config.data);
if (argv._.length > 0) {
  datasets = argv._;
}

async.eachSeries(datasets, function(dataset, outerCallback) {
  var importer = require('./' + path.join(dataset, dataset));

  console.log('Processing dataset ' + dataset.inverse + ':');
  async.eachSeries(steps, function(step, innerCallback) {
    if (!argv.steps || (argv.steps && argv.steps.split(',').indexOf(step) > -1) || step === 'done') {
      if (importer[step]) {
        console.log('  Executing step ' + step.underline + '...');

        importer[step](config.data[dataset], function(err) {
          if (err) {
            console.log('    Error: '.red + JSON.stringify(err));
          } else {
            console.log('    Done!'.green);
          }

          innerCallback(err);
        });
      } else {
        innerCallback();
      }
    } else {
      if (importer[step]) {
        console.log(('  Skipping step ' + step.underline + '...').gray);
      }

      innerCallback();
    }
  },

  function(err) {
    if (err) {
      console.log('Error: '.red + err);
    }

    outerCallback();
  });
},

function() {
  console.log('\nAll datasets done!'.green.underline);
});

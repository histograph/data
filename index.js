const path = require('path');
const async = require('async');
const config = require('histograph-config');
const parseArgs = require('minimist');
const log = require('histograph-logging');

const my_log = new log("data");

require('colors');

const steps = [
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

  my_log.info('Processing dataset ' + dataset.inverse + ':');
  async.eachSeries(steps, function(step, innerCallback) {
    if (!argv.steps || (argv.steps && argv.steps.split(',').indexOf(step) > -1) || step === 'done') {
      if (importer[step]) {
        my_log.info('  Executing step ' + step.underline + '...');

        importer[step](config.data[dataset], function(err) {
          if (err) {
            my_log.error('    Error: '.red + JSON.stringify(err));
          } else {
            my_log.info('    Done!'.green);
          }

          innerCallback(err);
        });
      } else {
        innerCallback();
      }
    } else {
      if (importer[step]) {
        my_log.info(('  Skipping step ' + step.underline + '...').gray);
      }

      innerCallback();
    }
  },

  function(err) {
    if (err) {
      my_info.error('Error: '.red + err);
    }

    outerCallback();
  });
},

function() {
  my_log.info('\nAll datasets done!'.green.underline);
});

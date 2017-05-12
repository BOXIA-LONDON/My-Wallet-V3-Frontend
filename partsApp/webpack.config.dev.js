
var DIST = Boolean(process.env.DIST);

var ExtractTextPlugin = require('extract-text-webpack-plugin');
var HtmlWebpackPlugin = require('html-webpack-plugin');

var entryRoot = __dirname + '/src';
var entryFile = entryRoot + '/app.js';
var outputRoot = DIST ? __dirname + './partsApp/dist' : __dirname + './partsApp/build';
var outputFilename = DIST ? '[name]-[hash].js' : '[name].js';

// TODO : Clean production related variables
// TODO : Add minification and hash for production script
// TODO : Add ES-Lint
// TODO : Exclude tests from production build

module.exports = {
  entry: entryFile,
  output: {
    path: outputRoot,
    filename: outputFilename
  },
  resolve: {
    alias: {
      'npm': `${__dirname}/../node_modules`,
      'bower': `${__dirname}/../bower_components`,
      'components': `${__dirname}/src/components`,
      'shared': `${__dirname}/src/shared`,
      'walletJs': `${__dirname}/../build/js`
    }
  },
  module: {
    // rules: [
    //   {
    //     enforce: 'pre',
    //     test: /\.js$/,
    //     exclude: ['npm', 'bower'],
    //     use: [{
    //       loader: 'eslint-loader',
    //       options: {
    //         failOnWarning: false,
    //         failOnError: true
    //       }
    //     }]
    //   }
    // ],
    loaders: [
      {
        test: /\.js$/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015']
        }
      },
      {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: ['css-loader', 'sass-loader']
        })
      },
      {
        test: /\.pug$/,
        use: [
          'html-loader',
          'pug-html-loader'
        ]
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin({
      filename: DIST ? '[name]-[hash].css' : '[name].css'
    }),
    new HtmlWebpackPlugin({
      template: entryRoot + '/app.html',
      filename: 'index.html'
    })
  ],
  devServer: {
    contentBase: outputRoot
  }
};

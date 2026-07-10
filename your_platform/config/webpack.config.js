var path = require('path');

module.exports = {
  entry: {
    your_platform_node_modules: path.resolve(__dirname, '..', 'app', 'vue', 'your_platform_node_modules.js'),
    vue_app: path.resolve(__dirname, '..', 'app', 'vue', 'VueApp.coffee'),
    //'webpack/hot/dev-server',
    //'webpack-dev-server/client?http://localhost:9000/',
  },
  output: {
    filename: '[name].pack.js',
    path: path.resolve(__dirname, '..', 'vendor', 'packs'),
    publicPath: 'http://localhost:9000/'
  },
  devServer: {
    port: 9000,
    // The dev-server runs in the web container (started by bin/dev) and
    // is reached from the host browser through the published port 9000,
    // see docker-compose.yml.
    host: '0.0.0.0',
    disableHostCheck: true,
    headers: { 'Access-Control-Allow-Origin': '*' }
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
        options: {
          presets: ["es2015"],
          hotReload: true
        }
      },
      {
        test: /\.js$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        options: {
          presets: ['es2015'],
        }
      },
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      },
      {
        test: /\.erb$/,
        enforce: 'pre',
        exclude: /node_modules/,
        use: [{
          loader: 'rails-erb-loader',
          options: {
            runner: (/^win/.test(process.platform) ? 'ruby ' : '') + 'bin/rails runner'
          }
        }]
      },
      { test: /\.(gif|svg|jpg|png)$/, loader: 'file-loader' },
      { test: /\.css$/, loader: 'style-loader!css-loader' },
    ]
  },
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },
};
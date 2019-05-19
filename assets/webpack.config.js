const path = require('path')
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const CssUrlRelativePlugin = require('css-url-relative-plugin')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');

module.exports = {
	entry: {
		bundle: './js/main.js'
	},
	output: {
		filename: path.join('js', '[name].js'),
		chunkFilename: path.join('js', '[name].[chunkhash].js'),
		path: path.resolve('..', 'priv', 'static'),
		publicPath: '/'
	},
	module: {
		rules: [{
			test: /\.vue$/,
			use: 'vue-loader'
		}, {
			test: /\.pug$/,
			loader: 'pug-plain-loader'
		}, {
			test: /\.js$/,
			use: [
				'babel-loader'
			]
		}, {
			test: /\.(sc|c|sa)ss$/,
			use: [{
					loader: MiniCssExtractPlugin.loader
				},
				'css-loader',
				'sass-loader'
			]
		}, {
			test: /\.woff2?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
			loader: 'url-loader'
		}, {
			test: /\.(ttf|eot|svg)(\?[\s\S]+)?$/,
			loader: 'file-loader',
			options: {
				outputPath: 'fonts'
			}
		}, {
			test: /\.(png|jpg|jpeg|gif)$/,
			loader: 'file-loader',
			options: {
				outputPath: 'images'
			}
		}, {
			test: [/robots\.txt$/, /\.ico$/],
			loader: 'file-loader',
			options: {
				name: '[name].[ext]'
			}
		}]
	},
	optimization: {
		minimizer: [
			new UglifyJsPlugin(),
			new OptimizeCSSAssetsPlugin()
		]
	},
	plugins: [
		new VueLoaderPlugin(),
		new MiniCssExtractPlugin({
			// Options similar to the same options in webpackOptions.output
			// both options are optional
			filename: path.join('css', '[name].css'),
			chunkFilename: path.join('css', '[name].css')
		}),
		new CleanWebpackPlugin(),
		new CssUrlRelativePlugin()
	]
};

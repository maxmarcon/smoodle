const path = require('path')
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const CssUrlRelativePlugin = require('css-url-relative-plugin')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');

const distPath = path.resolve('..', 'priv', 'static')
const jsPath = 'js'
const testPath = 'test'
const cssPath = 'css'
const fontsPath = 'fonts'
const imagesPath = 'images'

module.exports = {
	mode: 'development',
	entry: {
		bundle: './webpack-entry.js',
		testSuite: './js/test/suite.js'
	},
	output: {
		filename: (chunkData) => {
			return path.join((chunkData.chunk.name.match(/^test/) ? testPath : jsPath), '[name].js')
		},
		path: distPath,
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
				{
					loader: 'sass-loader',
					options: {
						data: '$fa-font-path: "~@fortawesome/fontawesome-free/webfonts"; $flag-icon-css-path: "~flag-icon-css/flags";'
					}
				}
			]
		}, {
			test: /\.woff2?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
			loader: 'url-loader'
		}, {
			test: /\.(ttf|eot|svg)(\?[\s\S]+)?$/,
			loader: 'file-loader',
			options: {
				outputPath: fontsPath
			}
		}, {
			test: /\.(png|jpg|jpeg|gif)$/,
			loader: 'file-loader',
			options: {
				outputPath: imagesPath
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
			filename: path.join(cssPath, '[name].css'),
			chunkFilename: path.join(cssPath, '[id].css')
		}),
		new CleanWebpackPlugin([
			path.join(distPath, '*.*'),
			path.join(distPath, jsPath),
			path.join(distPath, cssPath),
			path.join(distPath, fontsPath),
			path.join(distPath, imagesPath)
		], {
			allowExternal: true
		}),
		new CssUrlRelativePlugin()
	]
};
// const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const { config, environment } = require('@rails/webpacker')
const ManifestPlugin = require('webpack-manifest-plugin')

// const outputPath = `${config.outputPath}/${process.env.SITEKEY}`
// const outputPath = `${config.outputPath}`
// const publicPath = `${process.env.SITEKEY}${config.publicPath}`
// const publicPath = config.publicPath

// environment.plugins.append('Manifest', new ManifestPlugin({ publicPath, writeToFileEmit: true }))
//
// environment.config.merge({
//   output: {
//     publicPath,
//     path: outputPath
//   }
// })

// module.exports = environment
environment.loaders.prepend('erb', erb)
module.exports = environment

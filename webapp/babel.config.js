module.exports = {
  // TODO: can this be removed or does Edge still need it?
    presets: [
        ['@vue/app', {
            polyfills: [
                'es.array.includes'
            ]
        }]
    ]
}

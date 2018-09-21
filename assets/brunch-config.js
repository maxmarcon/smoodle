exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      //joinTo: {
      //  'js/bundle.js': '**/*.js'
      //},
      entryPoints: {
        'js/app.js': 'js/bundle.js'
      }
      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //   "js/app.js": /^js/,
      //   "js/vendor.js": /^(?!js)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "vendor/js/jquery-2.1.1.js",
      //     "vendor/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: 'css/bundle.css'
    }
    //templates: {
    //  joinTo: "js/bundle.js"
    //}
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/,
    ignored: ["js/socket.js", "css/phoenix.css"]
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["static", "js", "vendor", "scss"],
    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/],
      pattern: /\.(js)$/,
      presets: ['env']
    },
    copycat: {
      webfonts: ['node_modules/@fortawesome/fontawesome-free/webfonts'],
      flags: ['node_modules/flag-icon-css/flags']
    }
  },

  modules: {
    autoRequire: {
      "js/bundle.js": ["js/app"]
    }
  },

  overrides: {
    test: {
      conventions: {
        assets: /^(_static)/
      },
      plugins: {
        off: ['copycat-brunch']
      },
      files: {
        javascripts: {
          entryPoints: {
            'js/test/suite.js': 'testSuite.js'
          }
        },
        stylesheets: {
          joinTo: {
            'css/bundle.css': /^(_css)/
          }
        }
      },
      paths: {
        public: 'tests'
      },
      modules: {
        autoRequire: {
          "testSuite.js": ['js/test/suite']
        }
      }
    }
  }
};
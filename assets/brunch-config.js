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
      joinTo: "css/bundle.css"
    },
    templates: {
      joinTo: "js/templates.js"
    }
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
    watched: ["static", "js", "vendor", "sass"],
    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    },
    sass: {
      options: {
        includePaths: ["node_modules/bootstrap-sass/assets/stylesheets"], // tell sass-brunch where to look for files to @import
        precision: 8 // minimum precision required by bootstrap-sass 
      }
    },
    copycat: {
      "fonts": ["node_modules/bootstrap-sass/assets/fonts/bootstrap"] // copy node_modules/bootstrap-sass/assets/fonts/bootstrap/* to priv/static/fonts/
    }
  },

  modules: {
    autoRequire: {
      "js/bundle.js": ["js/app"]
    }
  },

  npm: {
    enabled: true
  }
};

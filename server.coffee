polar = require 'polar'
favicon = require './favicon'

config =
    DEBUG: false
    port: 4567

app = polar.setup_app
    port: config.port
    metaserve: compilers:
        'css\/(.*)\.css': [
            require('metaserve/src/compilers/raw/bouncer')
                base_dir: './static/css'
                ext: 'bounced.css'
                enabled: !config.DEBUG
            require('metaserve/src/compilers/css/styl')()
        ]
        'js\/(.*)\.js': [
            require('metaserve/src/compilers/raw/bouncer')
                base_dir: './static/js'
                ext: 'bounced.js'
                enabled: !config.DEBUG
            require('metaserve/src/compilers/js/browserify-coffee-jsx')
                ext: 'coffee'
        ]

app.get '/', (req, res) ->
    res.render 'base'

app.get '/favicon.png', (req, res) ->
    size = if req.query.size? then parseInt req.query.size else 16
    favicon(size).pipe(res)

app.start()


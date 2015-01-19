polar = require 'polar'
async = require 'async'
Redis = require 'redis'
redis = Redis.createClient null, null

config =
    DEBUG: false
    port: 4567

app = polar.setup_app
    port: config.port
    use_sessions: true
    session_secret: 'rrggbb112233'
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

app.get '/tags.json', (req, res) ->
    console.log req.session.id
    redis.keys "tags:#{req.session.id}:*", (err, tag_keys) ->
        console.log 'tag_keys', tag_keys
        tasks = {}
        tag_keys.map (tk) ->
            color = tk.split(':')[2]
            tasks[color] = (cb) ->
                redis.smembers tk, cb
        async.parallel tasks, (err, tags) ->
            res.json tags

app.post '/tags/:color', (req, res) ->
    saveTag req.params.color, req.body.name, req.session.id, (err, ok) ->
        res.end 'ok'

saveTag = (color, tag, session_id, cb) ->
    # Save to session's color list
    redis.sadd "tags:#{session_id}:#{color}", tag, (err, ok) ->
        # Save to global color list
        redis.sadd "tags:global:#{color}", tag, (err, ok) ->
            cb err, ok

app.start()


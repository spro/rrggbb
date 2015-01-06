React = require 'react/addons'
cx = React.addons.classSet

getBright = (c) ->
    c = parseInt c, 16
    r = (c >> 16) & 0xff
    g = (c >>  8) & 0xff
    b = (c >>  0) & 0xff
    bright = Math.max(0.6 * r, g, 0.3 * b)

randomColor = -> "000000".replace /0/g, ->
  (~~(Math.random() * 16)).toString 16

randomSquare = ->
    color = randomColor()
    square =
        color: color
        dark: getBright(color) < 48

Square = React.createClass
    getInitialState: ->
        randomSquare()

    render: ->
        square_class = cx
            'square': true
            'dark': @state.dark
        <div className={square_class} style={backgroundColor: '#'+@state.color}>
            {@state.color}
        </div>

AppView = React.createClass
    getInitialState: ->
        squares: [0..200]

    render: ->
        <div>
            {@state.squares.map Square}
        </div>

module.exports = AppView

React = require 'react/addons'
InfiniteScroll = require('react-infinite-scroll')(React)
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

    render: ->
        square_class = cx
            'square': true
            'dark': @props.dark
        <div className={square_class} style={backgroundColor: '#'+@props.color}>
            {@props.color}
        </div>

START_SQUARES = 100
MORE_SQUARES = 10

Squares = React.createClass
    getInitialState: ->
        squares: @getSquares START_SQUARES

    getSquares: (n) ->
        [0..n].map randomSquare

    moreSquares: ->
        @setState
            squares: @state.squares.concat @getSquares MORE_SQUARES

    render: ->
        <div>
            <InfiniteScroll
                pageStart=0
                loadMore={@moreSquares}
                hasMore={-> true}
            >
            {@state.squares.map Square}
            </InfiniteScroll>
        </div>

module.exports = Squares

$ = require 'jquery'
React = require 'react/addons'
_ = require 'underscore'

cx = React.addons.classSet

isDark = (c) -> getBright(c) < 58

getBright = (c) ->
    c = parseInt c, 16
    r = (c >> 16) & 0xff
    g = (c >>  8) & 0xff
    b = (c >>  0) & 0xff
    bright = Math.max(0.5 * r, g, 0.3 * b)

getRRGGBB = (c) ->
    c = parseInt c, 16
    r = (c >> 16) & 0xff
    g = (c >>  8) & 0xff
    b = (c >>  0) & 0xff
    [r ,g ,b]

colorDiff = (c1, c2) ->
    [rr1, gg1, bb1] = getRRGGBB(c1)
    [rr2, gg2, bb2] = getRRGGBB(c2)
    Math.sqrt((rr1-rr2)**2 + (gg1-gg2)**2 + (bb1-bb2)**2)

findClosestColors = (c1) ->
    starter =
        diff: 255.0
        color: if isDark c1 then 'ffffff' else '000000'
    all_colors = _.keys(colorTags)
    color_diffs = all_colors.map (c) ->
        {diff: colorDiff(c1, c), color: c}
    color_diffs = _.sortBy color_diffs, (cd) -> cd.diff

findClosestTags = (c1) ->
    closest = findClosestColors c1
    closest = closest.filter (cd) -> cd.diff < 60 and cd.diff != 0
    closest_colors = closest.slice(0,3).map (cd) -> cd.color
    closest_tags = []
    closest_colors.map (c) ->
        closest_tags = closest_tags.concat (colorTags[c] || [])
    _.uniq closest_tags

randomColor = -> "000000".replace /0/g, ->
  (~~(Math.random() * 16)).toString 16

randomSquare = ->
    color = randomColor()
    square =
        color: color
        dark: isDark color

colorTags = {}

$.get '/tags.json', (data) ->
    colorTags = data

TagsDispatcher =
    addTag: (color, tag) ->
        new_tag = tag
        colorTags[color] ||= []
        colorTags[color].push new_tag
        $.post '/tags/' + color, {name: new_tag}, ->
        return new_tag

Tag = React.createClass
    render: ->
        tag_class = cx
            'tag': true
            'suggested': @props.suggested
        <span className={tag_class}>
            {@props.tag}
            {<span className="plus" onClick={@props.addTag}>+</span> if @props.suggested}
        </span>

TagsPopover = React.createClass
    getInitialState: ->
        {tagged, suggested} = @getTags()
        return {
            tagged
            suggested
            new_tag_name: ''
        }

    getTags: ->
        tagged = colorTags[@props.color] || []
        suggested = _.difference (findClosestTags(@props.color) || []), tagged
        {tagged, suggested}

    componentDidMount: ->
        @focusInput()

    focusInput: ->
        @refs.input.getDOMNode().focus()

    enterTag: (e) ->
        e.preventDefault()
        @addTag @state.new_tag_name
        @setState new_tag_name: ''

    addTag: (t) ->
        TagsDispatcher.addTag @props.color, t
        @setState @getTags()

    setNewTagName: (e) ->
        e.preventDefault()
        @setState new_tag_name: e.target.value

    render: ->
        popover_class = cx
            'popover': true

        suggested = @state.suggested.map (t) =>
            <Tag tag={t} suggested={true} addTag={=> @addTag t}/>
        tagged = @state.tagged.map (t) ->
            <Tag tag={t} />

        <div className={popover_class} ref="container" onClick={@focusInput}>
            <div className="section">
                {tagged}
                {suggested}
                <form onSubmit={@enterTag}>
                    <input ref="input" type="text"
                        value={@state.new_tag_name} onChange={@setNewTagName}
                        placeholder="enter tag" />
                </form>
            </div>
        </div>

Square = React.createClass
    getInitialState: ->
        selected: false

    render: ->
        square_class = cx
            'square': true
            'dark': @props.square.dark
            'selected': @props.selected

        label_top = (@props.pos.h / 2) - 10
        if @props.selected
            label_top = 30

        <div className={square_class} style={
            backgroundColor: '#'+@props.square.color,
            left: @props.pos.x,
            top: @props.pos.y,
            width: @props.pos.w,
            height: @props.pos.h
        } onClick={@props.onClick}>
            <span className="color" style={top: label_top}>{@props.square.color}</span>
            {<TagsPopover color={@props.square.color} /> if @props.selected}
        </div>

START_SQUARES = 100
MORE_SQUARES = 10

w = 0
max = 8

setSizes = ->
    w = window.innerWidth * 1.0
    max = Math.floor(w/200)
    max = Math.max(max, 2)

setSizes()

makePos = (i) ->
    x: w * ((i % max) / max)
    y: Math.floor(i / max) * w / max
    w: w / max
    h: w / max

Squares = React.createClass
    getInitialState: ->
        squares: @getSquares START_SQUARES
        selected: -1

    componentWillMount: ->
        window.scrollTo(0, 0)

    componentDidMount: ->
        window.addEventListener 'scroll', @didScroll
        window.addEventListener 'resize', @didResize

    didScroll: ->
        total_size = makePos(@state.squares.length)
        console.log total_size
        total_h = total_size.y
        buffer =  window.innerHeight * 1.3
        should_load =  (window.scrollY + buffer) > total_h
        if should_load
            @moreSquares()

    didResize: ->
        setSizes()
        @forceUpdate()

    getSquares: (n) ->
        [0..n].map randomSquare

    moreSquares: ->
        @setState
            squares: @state.squares.concat @getSquares MORE_SQUARES

    selectSquare: (i) ->
        @setState selected: i

    render: ->
        squares = @state.squares.map (square, i) =>
            <Square square={square}
                pos={makePos i}
                onClick={=> @selectSquare i}
                selected={@state.selected == i} />

        <div id="squares">
            {squares}
        </div>

module.exports = Squares


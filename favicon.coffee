Canvas = require 'canvas'
renderFavicon = (size=16) ->
    s = size/2
    canvas = new Canvas(size, size)
    ctx = canvas.getContext('2d')

    randomColor = -> "#000000".replace /0/g, ->
      (~~(Math.random() * 16)).toString 16

    ctx.fillStyle = randomColor()
    ctx.fillRect(0, 0, s, s)
    ctx.fillStyle = randomColor()
    ctx.fillRect(s, 0, s, s)
    ctx.fillStyle = randomColor()
    ctx.fillRect(0, s, s, s)
    ctx.fillStyle = randomColor()
    ctx.fillRect(s, s, s, s)

    canvas.pngStream()

module.exports = renderFavicon

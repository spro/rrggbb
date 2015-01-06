$ = require 'jquery'
React = require 'react'
Squares = require './components/squares'

$ ->
    console.log "Welcome to rrggbb."
    React.render <Squares />, $('#app')[0]


$ = require 'jquery'
React = require 'react'
Squares = require './components/app-view'

$ ->
    console.log "Welcome to rrggbb."
    React.render <Squares />, $('#app')[0]


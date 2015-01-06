$ = require 'jquery'
React = require 'react'
AppView = require './components/app-view'

$ ->
    console.log "Welcome to rrggbb."
    React.render <AppView />, $('#app')[0]


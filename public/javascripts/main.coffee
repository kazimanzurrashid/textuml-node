require.config
  baseUrl: '/javascripts'
  paths:
    jquery: './../vendor/jquery/jquery'
    underscore: './../vendor/underscore/underscore'
    backbone: './../vendor/backbone/backbone'
    kinetic: './../vendor/kinetic/index'
    codemirror: './../vendor/codemirror/lib/codemirror'
    codemirrorActiveline: './../vendor/codemirror/addon/selection/active-line'
    codemirrorMarkSelection: './../vendor/codemirror/addon/selection/mark-selection'
    moment: './../vendor/moment/moment'
    'jquery.splitter': './../vendor/jQuery-Splitter/splitter'
    'bootstrap-transition': './../vendor/bootstrap/js/bootstrap-transition'
    'bootstrap-button': './../vendor/bootstrap/js/bootstrap-button'
    'bootstrap-modal': './../vendor/bootstrap/js/bootstrap-modal'
    'bootstrap-alert': './../vendor/bootstrap/js/bootstrap-alert'
    'bootstrap-tab': './../vendor/bootstrap/js/bootstrap-tab'
    'socket.io': './../vendor/socket.io-client/dist/socket.io'
    flashbar: 'application/lib/flashbar'
    confirm: 'application/lib/confirm'
    form: 'application/lib/form'
  shim:
    'jquery.splitter':
      deps: ['./../vendor/jquery.cookie/jquery.cookie']
      exports: '$'
    'bootstrap-modal':
      deps: [
        'jquery'
        'bootstrap-transition'
        'bootstrap-button'
      ]
      exports: '$'
    'bootstrap-alert':
      deps: [
        'jquery'
        'bootstrap-transition'
        'bootstrap-button'
      ]
      exports: '$'
    'bootstrap-tab':
      deps: [
        'jquery'
        'bootstrap-transition'
      ]
      exports: '$'
    'bootstrap-button':
      deps: [
        'jquery'
      ]
      exports: '$'
    underscore:
      exports: '_'
      init: ->
        @._.templateSettings =
          interpolate   : /\{\{(.+?)\}\}/g
        @._
    backbone:
      deps: ['jquery', 'underscore']
      exports: 'Backbone'
    codemirror:
      exports: 'CodeMirror'
    codemirrorMarkSelection:
      deps: ['codemirror']
    codemirrorActiveline:
      deps: ['codemirror']
    'socket.io':
      exports: 'io'

define (require) ->
  $           = require 'jquery'
  app         = require 'application/application'
  options     = require 'preloaded-data'

  $ -> app.start options

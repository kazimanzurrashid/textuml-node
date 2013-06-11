define (require) ->
  $         = require 'jquery'
  _         = require 'underscore'
  moment    = require 'moment'
  require 'form'

  formatAsRelativeTime: (date) ->
    moment(date).fromNow()

  formatAsHumanizeTime: (date) ->
    moment(date).format 'dddd, MMMM Do YYYY, h:mm a'

  hasModelErrors: (jqxhr) -> jqxhr.status is 400
  
  getModelErrors: (jqxhr) ->
    response = null
    try
      response = $.parseJSON jqxhr.responseText
    catch e
      response = null
    response

  subscribeModelInvalidEvent: (model, element) ->
    model.once 'invalid', ->
      element.showFieldErrors errors: model.validationError

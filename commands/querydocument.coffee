_ = require 'underscore'

Validation = require './validation'

class QueryDocument
  constructor: (attributes) ->
    @id = parseInt attributes?.id or 0, 10
    @userId = attributes?.userId

  validate: ->
    errors = {}

    Validation.addError errors, 'id', 'Id is required.' unless @id
    Validation.addError errors, 'userId', 'User is not set' unless @userId

    errors unless _(errors).isEmpty()

module.exports = QueryDocument
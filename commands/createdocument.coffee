_ = require 'underscore'

Validation = require './validation'

class CreateDocument
  constructor: (attributes) ->
    @title = attributes?.title
    @content = attributes?.content
    @userId = attributes?.userId

  validate: ->
    errors = {}

    Validation.addError errors, 'title', 'Title is required.' unless @title
    Validation.addError errors, 'userId', 'User is not set.' unless @userId

    errors unless _(errors).isEmpty()

module.exports = CreateDocument
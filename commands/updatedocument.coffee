_ = require 'underscore'

CreateDocument = require './createdocument'
Validation = require './validation'

class UpdateDocument extends CreateDocument
  constructor: (attributes) ->
    super
    @id = parseInt attributes?.id or 0, 10

  validate: ->
    errors = super or {}

    Validation.addError errors, 'id', 'Id is required.' unless @id

    errors unless _(errors).isEmpty()

module.exports = UpdateDocument
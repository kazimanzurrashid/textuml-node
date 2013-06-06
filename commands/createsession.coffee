_ = require 'underscore'

Validation = require './validation'

class CreateSession
  constructor: (attributes) ->
    @email = attributes?.email
    @password = attributes?.password

  validate: ->
    errors = {}

    Validation.addError errors, 'email', 'Email is required.' unless @email

    unless @password
      Validation.addError errors, 'password', 'Password is required.'

    errors unless _(errors).isEmpty()

module.exports = CreateSession
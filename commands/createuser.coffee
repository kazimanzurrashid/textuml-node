_ = require 'underscore'

Validation = require './validation'

class CreateUser
  constructor: (attributes) ->
    @email = attributes?.email
    @password = attributes?.password
    @confirmPassword = attributes?.confirmPassword
    @confirmed = attributes?.confirmed

  validate: ->
    errors = {}

    if @email
      unless Validation.isValidEmailFormat @email
        Validation.addError errors, 'email', 'Invalid email format.'
    else
      Validation.addError errors, 'email', 'Email is required.'

    if @password
      unless Validation.isValidPasswordLength @password
        Validation.addError errors, 'password', 'Password length must be ' +
        'between 6 to 64 characters.'
    else
      Validation.addError errors, 'password', 'Password is required.'

    if @confirmPassword
      if @password and @confirmPassword isnt @password
        Validation.addError errors, 'confirmPassword', 'Password and ' +
        'confirmation password do not match.'
    else
      Validation.addError errors, 'confirmPassword', 'Confirm password is ' +
      'required.'

    errors unless _(errors).isEmpty()

module.exports = CreateUser
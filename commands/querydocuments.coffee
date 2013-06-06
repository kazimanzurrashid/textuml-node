_ = require 'underscore'

Validation = require './validation'

sortAttributes = 'title createdAt updatedAt'.split ' '
sortOrders = 'asc desc'.split ' '

class QueryDocuments
  constructor: (attributes) ->
    @top = parseInt attributes?.top or 25, 10
    @skip = parseInt attributes?.skip or 0, 10
    @orderBy = attributes?.orderBy or 'updatedAt desc'
    @userId = attributes?.userId

  getOrderBy: ->
    direction = -1

    parts = @orderBy.split ' '
    attribute = parts[0]
    
    if parts.length is 2
      direction = if parts[1] is 'desc' then -1 else 1
    else
      direction = 1

    orderBy = { }
    orderBy[attribute] = direction

    JSON.stringify orderBy

  validate: ->
    errors = {}
    
    Validation.addError errors, 'top', 'Top cannot be negative.' if @top < 0
    Validation.addError errors, 'skip', 'Skip cannot be negative.' if @skip < 0
    
    parts = @orderBy.split ' '
    unless _(sortAttributes).contains parts[0]
      Validation.addError errors, 'orderBy', 'Invalid order by, only ' +
        "supports #{sortAttributes.join ', '} attribute."

    if parts.length is 2 and not _(sortOrders).contains parts[1]
      Validation.addError errors, 'orderBy', 'Invalid order by, only ' +
        "supports #{sortOrders.join ', '} order."

    Validation.addError errors, 'userId', 'User is not set.' unless @userId

    errors unless _(errors).isEmpty()

module.exports = QueryDocuments
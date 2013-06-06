_ = require 'underscore'
async = require 'async'

toDTO = (document) ->
  _(document)
    .chain()
    .omit('_id', 'userId')
    .defaults(id: document._id)
    .value()

module.exports = (Database, Sequence) ->
  all: (command, callback) ->
    criteria = userId: command.userId
    async.parallel
      count: (cb) -> Database.documents.count criteria, cb
      data: (cb) ->
        Database.documents.find(criteria)
          .sort(command.getOrderBy())
          .skip(command.skip)
          .limit command.top, cb
      , (err, results) ->
          return callback err if err
          dtos = _(results.data).map toDTO
          callback undefined, data: dtos, count: results.count

  one: (command, callback) ->
    criteria =
      _id: command.id
      userId: command.userId

    Database.documents.findOne criteria, (err, document) ->
      return callback err if err
      callback undefined, if document then toDTO document else undefined

  create: (command, callback) ->
    async.waterfall [
      (cb) -> Sequence.next 'documents', cb
      (id, cb) ->
        now = new Date

        document =
          _id           : id
          title         : command.title
          content       : command.content
          userId        : command.userId
          createdAt     : now
          updatedAt     : now

        Database.documents.insert document, cb
    ], (err, documents) ->
          return callback err if err
          callback undefined, toDTO _(documents).first()

  update: (command, callback) ->
    Database.documents.findAndModify
      query:
        _id: command.id
        userId: command.userId
      update:
        $set:
          title: command.title
          content: command.content
          updatedAt: new Date
      new: true
      (err, document) ->
        return callback err if err
        callback undefined, if document then toDTO document else undefined

  destroy: (command, callback) ->
    criteria =
      _id: command.id
      userId: command.userId

    Database.documents.remove criteria, (err, result) ->
      return callback err if err
      callback undefined, if result then true else false

  _destroy: (id, callback) -> Database.documents.remove { _id: id }, callback

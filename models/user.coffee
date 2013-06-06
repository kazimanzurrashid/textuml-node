_ = require 'underscore'
async = require 'async'

module.exports = (Crypto, Database, Sequence) ->
  exists: (email, callback) ->
    Database.users.findOne email: email.toLowerCase(), (err, user) ->
      return callback err if err
      callback undefined, if user then true else false

  create: (command, callback) ->
    async.parallel
      salt: Crypto.createToken
      authentication: Crypto.createToken
      confirmation: Crypto.createToken
    , (err, tokens) ->
        return callback err if err
        async.waterfall [
          (cb) -> Sequence.next 'users', cb
          (id, cb) ->
            hash = Crypto.createHash command.password, tokens.salt
            user =
              _id                       : id
              email                     : command.email.toLowerCase()
              salt                      : tokens.salt
              password                  : hash
              authenticationToken       : tokens.authentication
              confirmationToken         : tokens.confirmation
              confirmed                 : command.confirmed
              passwordResetToken        : null
              passwordResetExpiredAt    : null
              createdAt                 : new Date

            Database.users.insert user, cb
        ], (err, users) ->
          return callback err if err
          callback undefined, _(users).first()

  findBy: (attributes, callback) ->
    criteria = _(attributes).defaults confirmed: true
    Database.users.findOne criteria, callback

  authenticate: (command, callback) ->
    email = command.email.toLowerCase()

    Database.users.findOne { email, confirmed: true }, (err, user) ->
      return callback err if err
      return callback undefined, false unless user
      hash = Crypto.createHash command.password, user.salt
      return callback undefined, false unless user.password is hash
      callback undefined, user

  _destroy: (email, callback) -> Database.users.remove { email }, callback

Crypto = require 'crypto'

urlSafe = (value) -> value.replace(/\//g,'_').replace /\+/g,'-'

module.exports =
  createHash: (secret, salt) ->
    Crypto.createHmac('sha1', salt).update(secret).digest 'hex'

  createToken: (callback) ->
    Crypto.randomBytes 32, (err, buffer) ->
      return callback err if err
      token = urlSafe buffer.toString('base64')
      callback undefined, token
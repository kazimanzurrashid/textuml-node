cookie = require 'cookie'
connect = require 'connect'

module.exports = exports = (io, User, Document) ->
  io.set 'authorization', (handshakeData, callback) ->
    if handshakeData.headers.cookie
      handshakeData.cookie = cookie.parse handshakeData.headers.cookie
      handshakeData.sessionId = connect.utils
        .parseSignedCookie handshakeData.cookie['express.sid'], '$ecre8'
      if handshakeData.cookie['express.sid'] is handshakeData.sessionId
        return callback 'invalid cookie', false
    else
      return callback 'no cookie present', false

    callback null, true

  io.of('/documents')
    .on 'connection', (socket) ->
      console.log 'Socket.IO Connected'
define (require) ->
  io = require 'socket.io'
  socket = null

  start: ->
    socket = io.connect '/documents'
    socket.on 'connect', ->
      console.log 'socket.io connected'

  stop: ->
    return unless socket
    socket.disconnect()
    console.log 'socket.io disconnected'

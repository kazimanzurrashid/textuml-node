define(function(require) {
  var io, socket;
  io = require('socket.io');
  socket = null;
  return {
    start: function() {
      socket = io.connect('/documents');
      return socket.on('connect', function() {
        return console.log('socket.io connected');
      });
    },
    stop: function() {
      if (!socket) {
        return;
      }
      socket.disconnect();
      return console.log('socket.io disconnected');
    }
  };
});

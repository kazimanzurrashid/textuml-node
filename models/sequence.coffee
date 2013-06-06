module.exports = (Database) ->
  next: (name, callback) ->
    Database.sequences.findAndModify
      query:
        _id: name
      update:
        $inc:
          value: 1
      new: true
      upsert: true
      (err, sequence) ->
        return callback err if err
        callback undefined, sequence.value

  _current: (name, callback) ->
    Database.sequences.findOne { _id: name }, (err, sequence) ->
      return callback err if err
      currentId = sequence?.value
      callback undefined, currentId

  _reset: (name, id, callback) ->
    return Database.sequences.remove { _id: name }, callback unless id
    command =
      $set:
        value: id
    Database.sequences.update _id: name, command, callback
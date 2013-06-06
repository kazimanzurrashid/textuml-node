module.exports = exports = (QueryDocuments, QueryDocument, CreateDocument
, UpdateDocument, Document) ->

  index: (req, res) ->
    command = new QueryDocuments
      top       : req.params.top or req.query.top
      skip      : req.params.skip or req.query.skip
      orderBy   : req.params.orderBy or req.query.orderBy
      userId    : req.session.userId

    errors = command.validate()

    if errors
      return process.nextTick -> res.json 400, errors

    Document.all command, (err, result) ->
      if err
        console.dir err
        return res.send 500

      res.json result

  details: (req, res) ->
    command = new QueryDocument
      id        : req.params.id
      userId    : req.session.userId

    errors = command.validate()

    if errors
      return process.nextTick -> res.json 400, errors

    Document.one command, (err, document) ->
      if err
        console.dir err
        return res.send 500

      return res.send 404 unless document
      res.json document

  create: (req, res) ->
    command = new CreateDocument
      title     : req.body.title
      content   : req.body.content
      userId    : req.session.userId

    errors = command.validate()

    if errors
      return process.nextTick -> res.json 400, errors

    Document.create command, (err, document) ->
      if err
        console.dir err
        return res.send 500

      res.json 200, document
      
  update: (req, res) ->
    command = new UpdateDocument
      id        : req.params.id
      title     : req.body.title
      content   : req.body.content
      userId    : req.session.userId

    errors = command.validate()

    if errors
      return process.nextTick -> res.json 400, errors

    Document.update command, (err, document) ->
      if err
        console.dir err
        return res.send 500

      return res.send 404 unless document
      res.json document
    
  destroy: (req, res) ->
    command = new QueryDocument
      id        : req.params.id
      userId    : req.session.userId

    errors = command.validate()

    if errors
      return process.nextTick -> res.json 400, errors

    Document.destroy command, (err, deleted) ->
      if err
        console.dir err
        return res.send 500

      return res.send 404 unless deleted
      res.send 204

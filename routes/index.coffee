module.exports = exports = (QueryDocuments, Document) ->
  index: (req, res) ->
    userId = req.session.userId
    model =
      userSignedIn: if userId then true else false
      documents: { }

    return res.render 'index', model unless model.userSignedIn

    command = new QueryDocuments { userId }

    Document.all command, (err, result) ->
      if err
        console.dir err
        return res.send 500

      model.documents = result
      res.render 'index', model
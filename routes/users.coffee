module.exports = exports = (Command, User, requiresConfirmation) ->
  create: (req, res) ->
    command = new Command
      email               : req.body.email
      password            : req.body.password
      confirmPassword     : req.body.confirmPassword
      confirmed           : not requiresConfirmation

    errors = command.validate()

    if errors
      return process.nextTick -> res.json 400, errors

    User.exists command.email, (err1, exists) ->
      if err1
        console.dir err1
        return res.send 500

      return res.json 400, email: ['Email already exists.'] if exists

      User.create command, (err2, user) ->
        if err2
          console.dir err2
          return res.send 500

        # send email here
        res.send 204 # no content

module.exports = exports = (Command, User) ->
  create: (req, res) ->
    command = new Command
      email       : req.body.email
      password    : req.body.password

    errors = command.validate()

    if errors
      return process.nextTick -> res.json 400, errors

    User.authenticate command, (err, user) ->
      if err
        console.dir err
        return res.send 500

      return res.send 400 unless user

      req.session.userId = user._id

      if req.body.rememberMe
        expires = new Date
        expires.setDate expires.getDate() + 14 # 2 Weeks
        
        res.cookie 'signed-in-token', user.authenticationToken,
          expires     : expires
          httpOnly    : true
          signed      : true

      res.send 204 # no content

  destroy: (req, res) ->
    res.clearCookie 'signed-in-token'
    req.session.regenerate -> res.send 204 # no content

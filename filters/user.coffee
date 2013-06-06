module.exports = (User) ->
  load: (req, res, next) ->
    return next() if req.session.userId
    authenticationToken = req.signedCookies['signed-in-token']
    return next() unless authenticationToken
    User.findBy { authenticationToken }, (err, user) ->
      return next err if err
      req.session.userId = user._id if user
      next()

  requiresAuthentication: (req, res, next) ->
    return next() if req.session.userId
    res.send 403
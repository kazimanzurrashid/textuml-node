uri = process.env.MONGOLAB_URI or
  process.env.MONGOHQ_URI or
  'mongodb://localhost/textuml'

module.exports = require('mongojs').connect uri
  , ['sequences', 'users', 'documents']

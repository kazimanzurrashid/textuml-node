require('coffee-script');
var express = require('express')
, http = require('http')
, path = require('path');

var app = module.exports = express()
, server = http.createServer(app)
, io = require('socket.io').listen(server);

app.locals({
  title: 'Text Uml'
});

var session = express.session({
  secret: '$ecre8'
, key: 'express.sid'
});

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('$ecre8'));
  app.use(session);
  app.use(app.router);
  app.use(require('less-middleware')({
    src: __dirname + '/public'
  , compress: true
  }));  
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.configure('test', function(){
  app.set('port', process.env.PORT || 3001);
});

var Crypto = require('./lib/crypto') 
, CreateUserCommand = require('./commands/createuser')
, CreateSessionCommand = require('./commands/createsession')
, QueryDocumentsCommand = require('./commands/querydocuments')
, QueryDocumentCommand = require('./commands/querydocument')
, CreateDocumentCommand = require('./commands/createdocument')
, UpdateDocumentCommand = require('./commands/updatedocument')
, Database = require('./models/database')
, Sequence = require('./models/sequence')(Database)
, UserModel = require('./models/user')(Crypto, Database, Sequence)
, DocumentModel = require('./models/document')(Database, Sequence)
, UserFilter = require('./filters/user')(UserModel)
, HomeRouter = require('./routes')(QueryDocumentsCommand, DocumentModel)
, UsersRouter = require('./routes/users')
    (CreateUserCommand, UserModel, app.get('env') === 'production')
, SessionsRouter = require('./routes/sessions')
    (CreateSessionCommand, UserModel)
, DocumentsRouter = require('./routes/documents')
    (QueryDocumentsCommand, QueryDocumentCommand, CreateDocumentCommand
    , UpdateDocumentCommand, DocumentModel);

var ensureAuthenticated = [UserFilter.load, UserFilter.requiresAuthentication]

app.post('/users', UsersRouter.create);

app.post('/sessions', SessionsRouter.create);
app.del('/sessions', ensureAuthenticated, SessionsRouter.destroy);

app.put('/documents/:id', DocumentsRouter.update);
app.del('/documents/:id', DocumentsRouter.destroy);
app.get('/documents/:id', DocumentsRouter.details)
app.post('/documents', DocumentsRouter.create);
app.get('/documents', DocumentsRouter.index);
app.all('/documents/*', ensureAuthenticated);

app.get('/', UserFilter.load, HomeRouter.index);

server.listen(app.get('port'), function(){
  console.log('Application listening on port %d in %s mode.'
    , app.get('port')
    , app.settings.env);
});

require('./sockets/documents')(io, UserModel, DocumentModel);
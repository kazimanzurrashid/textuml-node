expect = require('chai').expect
sinon = require 'sinon'

describe 'units', ->

  describe 'models/user', ->
    database = null
    sequence = null
    crypto = null
    getUser = -> require('./../../../models/user')(crypto, database, sequence)
    email = 'user@example.com'
    password = '$ecre8'

    before ->
      crypto =
        createHash: ->
        createToken: ->

      database =
        users:
          findOne: ->
          insert: ->

      sequence =
        next: ->

    describe '.exits', ->
      stubbedDatabaseFindOne = null

      describe 'success', ->

        beforeEach ->
          stubbedDatabaseFindOne = sinon.stub database.users
          , 'findOne'
          , (attributes, callback) ->
              process.nextTick -> callback null, { }
      
        it 'returns boolean result', (done) ->
          getUser().exists email, (err, exists) ->
            expect(exists).to.be.true
            done()

        afterEach -> stubbedDatabaseFindOne.restore()

      describe 'failure', ->
        error = null

        beforeEach ->
          error = new Error
          stubbedDatabaseFindOne = sinon.stub database.users
          , 'findOne'
          , (attributes, callback) ->
              process.nextTick -> callback error
      
        it 'returns error', (done) ->
          getUser().exists email, (err, exists) ->
            expect(error).to.eql error
            expect(exists).to.be.undefined
            done()

        afterEach -> stubbedDatabaseFindOne.restore()

    describe '.create', ->
      stubbedCryptoHash = null
      stubbedCryptoToken = null

      before ->
        stubbedCryptoHash = sinon.stub crypto
        , 'createHash'
        , (secret, salt) -> secret + salt

      describe 'success', ->
        stubbedSequence = null
        stubbedDatabaseInsert = null

        beforeEach ->
          stubbedCryptoToken = sinon.stub crypto
          , 'createToken'
          , (callback) -> process.nextTick -> callback null, 'token'

          stubbedSequence = sinon.stub sequence
          , 'next', (name, callback) -> process.nextTick -> callback null, 1

          stubbedDatabaseInsert  = sinon.stub database.users
          , 'insert'
          , (attributes, callback) ->
              process.nextTick -> callback null, [attributes]

        it 'returns new user', (done) ->
          command =
            email: email
            password: password
            confirmPassword: password

          getUser().create command, (err, user) ->
            expect(user._id).to.equal 1
            expect(user.email).to.equal command.email
            expect(user.salt).to.exit
            expect(user.password).to.not.equal command.password
            expect(user.authenticationToken).to.not.undefined
            expect(user.confirmationToken).to.exit
            expect(user.confirmed).to.undefined
            expect(user.passwordResetToken).to.not.undefined
            expect(user.passwordResetExpiredAt).to.not.undefined
            expect(user.createdAt).to.exist
            done()

        afterEach ->
          stubbedCryptoToken.restore()
          stubbedSequence.restore()
          stubbedDatabaseInsert.restore()

      describe 'failure', ->
        error = null

        beforeEach ->
          error = new Error
          stubbedCryptoToken = sinon.stub crypto
          , 'createToken', (callback) -> process.nextTick -> callback error

        it 'returns error', (done) ->
          command =
            email: email
            password: password
            confirmPassword: password

          getUser().create command, (err, user) ->
            expect(err).to.eql error
            expect(user).to.be.undefined
            done()

        afterEach -> stubbedCryptoToken.restore()

      after -> stubbedCryptoHash.restore()

    describe '.authenticate', ->
      stubbedDatabaseFindOne = null

      describe 'success', ->
        stubbedCryptoHash = null
        user = null

        beforeEach ->
          user =
            salt: '1234567890'
            password: password

          stubbedDatabaseFindOne = sinon.stub database.users
          , 'findOne'
          , (attributes, callback) ->
              process.nextTick -> callback null, user
      
          stubbedCryptoHash = sinon.stub crypto
          , 'createHash', (secret, salt) -> secret

        it 'returns user', (done) ->
          getUser().authenticate { email, password }, (err, usr) ->
            expect(usr).to.eql user
            done()

        afterEach ->
          stubbedDatabaseFindOne.restore()
          stubbedCryptoHash.restore()

      describe 'failure', ->
        error = null

        beforeEach ->
          error = new Error
          stubbedDatabaseFindOne = sinon.stub database.users
          , 'findOne'
          , (attributes, callback) -> process.nextTick -> callback error
      
        it 'returns error', (done) ->
          getUser().authenticate { email, password }, (err, exists) ->
            expect(error).to.eql error
            expect(exists).to.be.undefined
            done()

        afterEach -> stubbedDatabaseFindOne.restore()
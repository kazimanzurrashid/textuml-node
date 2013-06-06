superagent = require 'superagent'
_ = require 'underscore'
chai = require 'chai'
expect = chai.expect

testUrl = require('./../../helpers').testUrl
repeatString = require('./../../helpers').repeatString
Crypto = require './../../../lib/crypto'
Database = require './../../../models/database'
Sequence = require('./../../../models/sequence')(Database)
User = require('./../../../models/user')(Crypto, Database, Sequence)

describe 'integrations', ->

  describe 'routers/users', ->
    email = "user_#{Date.now()}@example.com"
    password = '$ecre8'

    describe 'POST', ->
      response = null

      describe 'success', ->
        currentUserSequence = null

        before (done) ->
          Sequence._current 'users', (err1, id) ->
            return done err1 if err1

            currentUserSequence = id

            superagent
              .agent()
              .post(testUrl '/users')
              .send(email: email
                , password: password
                , confirmPassword: password)
              .end (err2, res) ->
                return done err2 if err2
                response = res
                done()
            
        it 'returns http status code 204', ->
          expect(response.status).to.equal 204

        after (done) ->
          User._destroy email, (err) ->
            return done err if err
            Sequence._reset 'users', currentUserSequence, done
            
      describe 'failure', ->

        describe 'validation', ->

          describe 'email', ->

            describe 'missing', ->

              before (done) ->
                superagent
                  .agent()
                  .post(testUrl '/users')
                  .send(password: password, confirmPassword: password)
                  .end (err, res) ->
                    return done err if err
                    response = res
                    done()
                  
              it 'returns http status code 400', ->
                expect(response.status).to.equal 400

              it 'returns json', -> expect(response).to.be.json

              it 'returns email error', ->
                errors = JSON.parse response.text
                expect(errors).to.have.property 'email'
                expect(_(errors.email).first())
                  .to
                  .equal 'Email is required.'

            describe 'incorrect format', ->

              before (done) ->
                superagent
                  .agent()
                  .post(testUrl '/users')
                  .send(email: 'foo-bar'
                    , password: password
                    , confirmPassword: password)
                  .end (err, res) ->
                    return done err if err
                    response = res
                    done()
                  
              it 'returns http status code 400', ->
                expect(response.status).to.equal 400

              it 'returns json', -> expect(response).to.be.json

              it 'returns email error', ->
                errors = JSON.parse response.text
                expect(errors).to.have.property 'email'
                expect(_(errors.email).first())
                  .to
                  .equal 'Invalid email format.'

          describe 'password', ->

            describe 'missing', ->
              before (done) ->
                superagent
                  .agent()
                  .post(testUrl '/users')
                  .send(email: email, confirmPassword: password)
                  .end (err, res) ->
                    return done err if err
                    response = res
                    done()

              it 'returns http status code 400', ->
                expect(response.status).to.equal 400

              it 'returns json', -> expect(response).to.be.json

              it 'returns password error', ->
                errors = JSON.parse response.text
                expect(errors).to.have.property 'password'
                expect(_(errors.password).first())
                  .to
                  .equal 'Password is required.'

            describe 'incorrect length', ->

              before (done) ->
                superagent
                  .agent()
                  .post(testUrl '/users')
                  .send(email: email
                    , password: repeatString 5
                    , confirmPassword: repeatString 5)
                  .end (err, res) ->
                    return done err if err
                    response = res
                    done()
                  
              it 'returns http status code 400', ->
                expect(response.status).to.equal 400

              it 'returns json', -> expect(response).to.be.json

              it 'returns email error', ->
                errors = JSON.parse response.text
                expect(errors).to.have.property 'password'
                expect(_(errors.password).first())
                  .to
                  .equal 'Password length must be between 6 to 64 characters.'

          describe 'confirmPassword', ->

            describe 'missing', ->

              before (done) ->
                superagent
                  .agent()
                  .post(testUrl '/users')
                  .send(email: email, password: password)
                  .end (err, res) ->
                    return done err if err
                    response = res
                    done()
                  
              it 'returns http status code 400', ->
                expect(response.status).to.equal 400

              it 'returns json', -> expect(response).to.be.json

              it 'returns confirm password error', ->
                errors = JSON.parse response.text
                expect(errors).to.have.property 'confirmPassword'
                expect(_(errors.confirmPassword).first())
                  .to
                  .equal 'Confirm password is required.'

            describe 'does not match password', ->

              before (done) ->
                superagent
                  .agent()
                  .post(testUrl '/users')
                  .send(email: email
                    , password: password
                    , confirmPassword: 'foo-bar')
                  .end (err, res) ->
                    return done err if err
                    response = res
                    done()
                  
              it 'returns http status code 400', ->
                expect(response.status).to.equal 400

              it 'returns json', -> expect(response).to.be.json

              it 'returns email error', ->
                errors = JSON.parse response.text
                expect(errors).to.have.property 'confirmPassword'
                expect(_(errors.confirmPassword).first())
                  .to
                  .equal 'Password and confirmation password do not match.'

        describe 'duplicate email', ->
          currentUserSequence = null

          before (done) ->
            Sequence._current 'users', (err1, id) ->
              return done err1 if err1

              currentUserSequence = id
              
              User.create { email, password, confirmPassword: password }
              , (err2) ->
                  return done err2 if err2

                  superagent
                    .agent()
                    .post(testUrl '/users')
                    .send(email: email
                      , password: password
                      , confirmPassword: password)
                    .end (err3, res) ->
                      return done err3 if err3
                      response = res
                      done()
              
          it 'returns http status code 400', ->
            expect(response.status).to.equal 400

          it 'returns json', -> expect(response).to.be.json

          it 'returns email error', ->
            errors = JSON.parse response.text
            expect(errors).to.have.property 'email'
            expect(_(errors.email).first())
              .to.equal 'Email already exists.'

          after (done) ->
            User._destroy email, (err) ->
              return done err if err
              Sequence._reset 'users', currentUserSequence, done
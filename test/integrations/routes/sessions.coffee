superagent = require 'superagent'
_ = require 'underscore'
chai = require 'chai'
expect = chai.expect

testUrl = require('./../../helpers').testUrl
Crypto = require './../../../lib/crypto'
Database = require './../../../models/database'
Sequence = require('./../../../models/sequence')(Database)
User = require('./../../../models/user')(Crypto, Database, Sequence)

describe 'integrations', ->

  describe 'routers/sessions', ->

    email = "user_#{Date.now()}@example.com"
    password = '$ecre8'

    response = null

    describe 'POST', ->

      describe 'success', ->
        currentUserSequence = null

        before (done) ->
          Sequence._current 'users', (err, id) ->
            return done err if err

            currentUserSequence = id

            attributes =
              email: email
              password: password
              confirmPassword: password
              confirmed: true

            User.create attributes, done

        describe 'non persistent cookie', ->

          before (done) ->
            superagent
              .agent()
              .post(testUrl '/sessions')
              .send(email: email, password: password)
              .end (err, res) ->
                return done err if err
                response = res
                done()

          it 'returns http status code 204', ->
            expect(response.status).to.equal 204

        describe 'persistent cookie', ->

          before (done) ->
            superagent
              .agent()
              .post(testUrl '/sessions')
              .send(email: email, password: password, rememberMe: true)
              .end (err, res) ->
                return done err if err
                response = res
                done()

          it 'returns http status code 204', ->
            expect(response.status).to.equal 204

          it 'issues cookie', ->
            header = response.header['set-cookie'][0]
            expect(header).to.contain 'signed-in-token'

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
                  .post(testUrl '/sessions')
                  .send(password: password)
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

          describe 'password', ->

            describe 'missing', ->

              before (done) ->
                superagent
                  .agent()
                  .post(testUrl '/sessions')
                  .send(email: email)
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

        describe 'user does not exist', ->

          before (done) ->
            superagent
              .agent()
              .post(testUrl '/sessions')
              .send(email: email, password: password)
              .end (err, res) ->
                return done err if err
                response = res
                done()
              
          it 'returns http status code 400', ->
            expect(response.status).to.equal 400

        describe 'user is not confirmed', ->
          currentUserSequence = null

          before (done) ->
            Sequence._current 'users', (err, id) ->
              return done err if err

              currentUserSequence = id

              attributes =
                email: email
                password: password
                confirmPassword: password
                confirmed: false

              User.create attributes, done

          beforeEach (done) ->
            superagent
              .agent()
              .post(testUrl '/sessions')
              .send(email: email, password: password)
              .end (err, res) ->
                return done err if err
                response = res
                done()
              
          it 'returns http status code 400', ->
            expect(response.status).to.equal 400

          after (done) ->
            User._destroy email, (err) ->
              return done err if err
              Sequence._reset 'users', currentUserSequence, done

    describe 'DELETE', ->

      describe 'success', ->

        describe 'user is authenticated', ->

          currentUserSequence = null

          before (done) ->
            Sequence._current 'users', (err1, id) ->
              return done err1 if err1

              currentUserSequence = id

              attributes =
                email: email
                password: password
                confirmPassword: password
                confirmed: true

              User.create attributes, (err2) ->
                return done err2 if err2

                agent = superagent.agent()

                agent
                  .post(testUrl '/sessions')
                  .send(email: email, password: password)
                  .end (err3, res1) ->
                    return done err3 if err3
                    agent.saveCookies res1

                    agent
                      .del(testUrl '/sessions')
                      .end (err4, res2) ->
                        return done err4 if err4
                        response = res2
                        done()

          it 'returns http status code 204', ->
            expect(response.status).to.equal 204

          after (done) ->
            User._destroy email, (err) ->
              return done err if err
              Sequence._reset 'users', currentUserSequence, done

      describe 'failure', ->

        describe 'user is not authenticated', ->

          before (done) ->
            superagent
              .agent()
              .del(testUrl '/sessions')
              .end (err, res) ->
                return done err if err
                response = res
                done()
                
          it 'returns http status code 403', ->
            expect(response.status).to.equal 403

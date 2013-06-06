superagent = require 'superagent'
_ = require 'underscore'
chai = require 'chai'
expect = chai.expect

testUrl = require('./../../helpers').testUrl
Crypto = require './../../../lib/crypto'
Database = require './../../../models/database'
Sequence = require('./../../../models/sequence')(Database)
User = require('./../../../models/user')(Crypto, Database, Sequence)
Document = require('./../../../models/document')(Database, Sequence)

describe 'integrations', ->

  describe 'routers/documents', ->

    email = "user_#{Date.now()}@example.com"
    password = '$ecre8'

    userId = null
    currentUserSequence = null

    agent = null
    response = null

    before (done) ->
      Sequence._current 'users', (err1, id) ->
        return done err1 if err1

        currentUserSequence = id

        attributes =
          email: email
          password: password
          confirmPassword: password
          confirmed: true

        User.create attributes, (err2, user) ->
          return done err2 if err2

          userId = user._id

          agent = superagent.agent()

          agent
            .post(testUrl '/sessions')
            .send(email: email, password: password)
            .end (err3, res) ->
              return done err3 if err3
              agent.saveCookies res
              done()

    describe 'POST', ->

      describe 'success', ->
        currentDocumentSequence = null
        attributes = null
        document = null

        before (done) ->
          document = null

          Sequence._current 'documents', (err1, id) ->
            return done err1 if err1
            currentDocumentSequence = id

            attributes =
              title: 'my diagram'
              content: 'A -> B: Method1'

            agent
              .post(testUrl '/documents')
              .send(attributes)
              .end (err2, res) ->
                return done err2 if err2
                response = res
                done()
                
        it 'returns http status code 200', ->
          expect(response.status).to.equal 200

        it 'returns json', -> expect(response).to.be.json

        it 'returns new document', ->
          document = JSON.parse response.text
          expect(document.title).to.equal attributes.title
          expect(document.content).to.equal attributes.content
          expect(document.createdAt).to.exist
          expect(document.updatedAt).to.exist
          expect(document.id).to.exist

        after (done) ->
          Sequence._reset 'documents', currentDocumentSequence, (err) ->
            return done err if err
            return Document._destroy document.id, done if document
            done()

      describe 'failure', ->

        describe 'validation', ->

          describe 'title', ->

            describe 'missing', ->

              before (done) ->
                agent
                  .post(testUrl '/documents')
                  .send(content: 'foo-bar')
                  .end (err, res) ->
                    return done err if err
                    response = res
                    done()

              it 'returns http status code 400', ->
                expect(response.status).to.equal 400

              it 'returns json', -> expect(response).to.be.json

              it 'returns title error', ->
                errors = JSON.parse response.text
                expect(errors).to.have.property 'title'
                expect(_(errors.title).first())
                  .to
                  .equal 'Title is required.'

    describe 'PUT', ->
      currentDocumentSequence = null
      documentId = null

      before (done) ->
        documentId = null

        Sequence._current 'documents', (err1, id) ->
          return done err1 if err1

          currentDocumentSequence = id

          attributes =
            title: 'my dummy diagram'
            content: 'A -> B: Method1'
            userId: userId

          Document.create attributes, (err2, document) ->
            return done err2 if err2
            documentId = document.id
            done()

      describe 'success', ->
        attributes = null

        before (done) ->
          attributes =
            title: 'my modified diagram'
            content: 'C -> D: Method1'

          agent
            .put(testUrl "/documents/#{documentId}")
            .send(attributes)
            .end (err, res) ->
              return done err if err
              response = res
              done()
                
        it 'returns http status code 200', ->
          expect(response.status).to.equal 200

        it 'returns json', -> expect(response).to.be.json
          
        it 'returns updated document', ->
          document = JSON.parse response.text
          expect(document.title).to.equal attributes.title
          expect(document.content).to.equal attributes.content

      describe 'failure', ->

        describe 'does not exist', ->

          before (done) ->
            attributes =
              title: 'my modified diagram'
              content: 'C -> D: Method1'

            agent
              .put(testUrl "/documents/#{Date.now()}")
              .send(attributes)
              .end (err, res) ->
                return done err if err
                response = res
                done()

          it 'returns http status code 404', ->
            expect(response.status).to.equal 404

        describe 'validation', ->

          describe 'title', ->

            describe 'missing', ->

              before (done) ->
                agent
                  .put(testUrl "/documents/#{documentId}")
                  .send(content: 'foo-bar')
                  .end (err, res) ->
                    return done err if err
                    response = res
                    done()

              it 'returns http status code 400', ->
                expect(response.status).to.equal 400

              it 'returns json', -> expect(response).to.be.json

              it 'returns title error', ->
                errors = JSON.parse response.text
                expect(errors).to.have.property 'title'
                expect(_(errors.title).first())
                  .to
                  .equal 'Title is required.'

      after (done) ->
        Sequence._reset 'documents', currentDocumentSequence, (err) ->
          return done err if err
          Document._destroy documentId, done

    describe 'DELETE', ->
      currentDocumentSequence = null
      documentId = null

      before (done) ->
        documentId = null

        Sequence._current 'documents', (err1, id) ->
          return done err1 if err1

          currentDocumentSequence = id

          attributes =
            title: 'my dummy diagram'
            content: 'A -> B: Method1'
            userId: userId

          Document.create attributes, (err2, document) ->
            return done err2 if err2
            documentId = document.id
            done()

      describe 'success', ->

        before (done) ->
          agent
            .del(testUrl "/documents/#{documentId}")
            .end (err, res) ->
              return done err if err
              response = res
              done()
                
        it 'returns http status code 204', ->
          expect(response.status).to.equal 204

      describe 'failure', ->

        describe 'does not exist', ->

          before (done) ->
            agent
              .del(testUrl "/documents/#{Date.now()}")
              .end (err, res) ->
                return done err if err
                response = res
                done()

          it 'returns http status code 404', ->
            expect(response.status).to.equal 404

      after (done) ->
        Sequence._reset 'documents', currentDocumentSequence, done
      
    after (done) ->
      User._destroy email, (err) ->
        return done err if err
        Sequence._reset 'users', currentUserSequence, done
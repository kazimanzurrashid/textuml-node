superagent = require 'superagent'
chai = require 'chai'
expect = chai.expect

testUrl = require('./../../helpers').testUrl

describe 'integrations', ->

  describe 'routers/index', ->

    describe 'GET', ->
      response = null

      before (done) ->
        superagent
          .agent()
          .get(testUrl())
          .end (err, res) ->
            return done err if err
            response = res
            done()
            
      it 'returns http status code 200', ->
        expect(response.status).to.equal 200

      it 'returns html', -> expect(response).to.be.html

      it 'has title', ->
        expect(response.text).to.contain '<title>Text Uml</title>'

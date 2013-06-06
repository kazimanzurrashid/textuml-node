expect = require('chai').expect

Database = require('./../../../models/database')
Sequence = require('./../../../models/sequence') (Database)

describe 'integrations', ->

  describe 'models/sequence', ->

    describe '.next', ->
      current = null

      before (done) ->
        currentId = null
        Sequence._current 'users', (err, id) ->
          return done err if err
          current = id or 0
          done()

      it 'increments by one', (done) ->
        Sequence.next 'users', (err, id) ->
          return done err if err
          expect(id).to.equal current + 1
          done()

      after (done) -> Sequence._reset 'users', current, done
expect = require('chai').expect
sinon = require 'sinon'

describe 'units', ->

  describe 'models/sequence', ->
    database = null
    getSequence = -> require('./../../../models/sequence')(database)

    before ->
      database = { sequences: { findAndModify: (command, callback) -> } }

    describe '.nextId', ->
      stub = null

      describe 'success', ->

        beforeEach ->
          stub = sinon.stub database.sequences
          , 'findAndModify'
          , (command, callback) ->
            process.nextTick -> callback null, { value: 1 }

        it 'returns new id', (done) ->
          getSequence().next 'tests', (err, id) ->
            expect(id).to.equal 1
            done()

        afterEach -> stub.restore()

      describe 'failure', ->
        error = null

        beforeEach ->
          error = new Error
          stub = sinon.stub database.sequences
          , 'findAndModify'
          , (command, callback) ->
            process.nextTick -> callback error

        it 'returns error', (done) ->
          Sequence = getSequence database
          Sequence.next 'tests', (err, id) ->
            expect(err).to.eql error
            expect(id).to.be.undefined
            done()

        afterEach -> stub.restore()
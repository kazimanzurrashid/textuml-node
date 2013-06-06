expect = require('chai').expect
_ = require 'underscore'

UpdateDocument = require './../../../commands/updatedocument'

describe 'units', ->

  describe 'commands/updatedocument', ->
    command = null

    describe '#constructor', ->
      attributes = null

      before ->
        attributes =
          title: 'Dummy Diagram'
          content: 'A -> B: Method1'
          userId: 1
          id: 99
          
        command = new UpdateDocument attributes

      it 'has same #title', -> expect(command.title).to.equal attributes.title

      it 'has same #content', ->
        expect(command.content).to.equal attributes.content

      it 'has same #userId', ->
        expect(command.userId).to.equal attributes.userId

      it 'has same #id', ->
        expect(command.id).to.equal attributes.id
        
    describe '#validate', ->
      errors = null

      describe 'no errors', ->

        before ->
          command = new UpdateDocument
            title: 'Dummy Diagram'
            userId: 1
            id: 99
          errors = command.validate()

        it 'returns nothing', -> expect(errors).to.be.undefined

      describe 'errors', ->

        describe 'everything missing', ->

          before ->
            command = new UpdateDocument
            errors = command.validate()

          it 'returns title error', ->
            expect(errors).to.have.property 'title'
            expect(_(errors.title).first()).to.equal 'Title is required.'

          it 'returns id error', ->
            expect(errors).to.have.property 'id'
            expect(_(errors.id).first()).to.equal 'Id is required.'

          it 'returns userId error', ->
            expect(errors).to.have.property 'userId'
            expect(_(errors.userId).first()).to.equal 'User is not set.'
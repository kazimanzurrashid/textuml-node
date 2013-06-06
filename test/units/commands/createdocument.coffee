expect = require('chai').expect
_ = require 'underscore'

CreateDocument = require './../../../commands/createdocument'

describe 'units', ->

  describe 'commands/createdocument', ->
    command = null

    describe '#constructor', ->
      attributes = null

      before ->
        attributes =
          title: 'Dummy Diagram'
          content: 'A -> B: Method1'
          userId: 1
          
        command = new CreateDocument attributes

      it 'has same #title', -> expect(command.title).to.equal attributes.title

      it 'has same #content', ->
        expect(command.content).to.equal attributes.content

      it 'has same #userId', ->
        expect(command.userId).to.equal attributes.userId

    describe '#validate', ->
      errors = null

      describe 'no errors', ->

        before ->
          command = new CreateDocument
            title: 'Dummy Diagram'
            userId: 1
          errors = command.validate()

        it 'returns nothing', -> expect(errors).to.be.undefined

      describe 'errors', ->

        describe 'everything missing', ->

          before ->
            command = new CreateDocument
            errors = command.validate()

          it 'returns title error', ->
            expect(errors).to.have.property 'title'
            expect(_(errors.title).first()).to.equal 'Title is required.'

          it 'returns userId error', ->
            expect(errors).to.have.property 'userId'
            expect(_(errors.userId).first()).to.equal 'User is not set.'
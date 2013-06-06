expect = require('chai').expect
_ = require 'underscore'

QueryDocuments = require './../../../commands/querydocuments'

describe 'units', ->

  describe 'commands/querydocuments', ->
    command = null

    describe '#constructor', ->

      describe 'explicit', ->
        attributes = null

        before ->
          attributes =
            top: 30
            skip: 100
            orderBy: 'title asc'
            userId: 1
            
          command = new QueryDocuments attributes

        it 'has same #top', -> expect(command.top).to.equal attributes.top

        it 'has same #skip', ->
          expect(command.skip).to.equal attributes.skip

        it 'has same #orderBy', ->
          expect(command.orderBy).to.equal 'title asc'

        it 'has same #userId', ->
          expect(command.userId).to.equal attributes.userId

      describe 'default', ->

        before -> command = new QueryDocuments

        it 'sets #top to 25', -> expect(command.top).to.equal 25

        it 'sets #skip to 0', -> expect(command.skip).to.equal 0

        it 'sets #orderBy to updatedAt desc', ->
          expect(command.orderBy).to.equal 'updatedAt desc'

    describe '#validate', ->
      errors = null

      describe 'no errors', ->

        before ->
          command = new QueryDocuments
            top: 30
            skip: 100
            orderBy: 'title asc'
            userId: 1
          errors = command.validate()

        it 'returns nothing', -> expect(errors).to.be.undefined

      describe 'errors', ->

        describe 'negative #top', ->

          before ->
            command = new QueryDocuments
              top: -5
            errors = command.validate()

          it 'returns error', ->
            expect(errors).to.have.property 'top'
            expect(_(errors.top).first()).to.equal 'Top cannot be negative.'

        describe 'negative #skip', ->

          before ->
            command = new QueryDocuments
              skip: -40
            errors = command.validate()

          it 'returns error', ->
            expect(errors).to.have.property 'skip'
            expect(_(errors.skip).first()).to.equal 'Skip cannot be negative.'

        describe 'unknown sort attribute', ->

          before ->
            command = new QueryDocuments
              orderBy: 'foo asc'
            errors = command.validate()

          it 'returns error', ->
            expect(errors).to.have.property 'orderBy'
            expect(_(errors.orderBy).first())
              .to
              .equal 'Invalid order by, only supports title, createdAt, ' +
                'updatedAt attribute.'

        describe 'unknown sort order', ->

          before ->
            command = new QueryDocuments
              orderBy: 'createdAt foo'
            errors = command.validate()

          it 'returns error', ->
            expect(errors).to.have.property 'orderBy'
            expect(_(errors.orderBy).first())
              .to
              .equal 'Invalid order by, only supports asc, desc order.'

        describe 'no #userId', ->

          before ->
            command = new QueryDocuments
              top: 30
              skip: 100
              orderBy: 'title asc'

            errors = command.validate()

          it 'returns error', ->
            expect(errors).to.have.property 'userId'
            expect(_(errors.userId).first()).to.equal 'User is not set.'
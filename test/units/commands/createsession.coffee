expect = require('chai').expect
_ = require 'underscore'

CreateSession = require './../../../commands/createsession'

describe 'units', ->

  describe 'commands/createsession', ->
    email = 'user@example.com'
    password = '$ecre8'

    command = null

    describe '#constructor', ->

      attributes = null

      before ->
        attributes =
          email: email
          password: password
          
        command = new CreateSession attributes

      it 'has same #email', -> expect(command.email).to.equal attributes.email

      it 'has same #password', ->
        expect(command.password).to.equal attributes.password

    describe '#validate', ->
      errors = null

      describe 'no errors', ->

        before ->
          command = new CreateSession
            email: email
            password: password
          errors = command.validate()

        it 'returns nothing', -> expect(errors).to.be.undefined

      describe 'errors', ->

        describe 'everything missing', ->

          before ->
            command = new CreateSession
            errors = command.validate()

          it 'returns email error', ->
            expect(errors).to.have.property 'email'
            expect(_(errors.email).first()).to.equal 'Email is required.'

          it 'returns password error', ->
            expect(errors).to.have.property 'password'
            expect(_(errors.password).first()).to.equal 'Password is required.'
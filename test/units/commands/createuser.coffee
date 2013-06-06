expect = require('chai').expect
_ = require 'underscore'

repeatString = require('./../../helpers').repeatString
CreateUser = require './../../../commands/createuser'

describe 'units', ->

  describe 'commands/createuser', ->
    email = 'user@example.com'
    password = '$ecre8'

    command = null

    describe '#constructor', ->
      attributes = null

      before ->
        attributes =
          email: email
          password: password
          confirmPassword: password
          confirmed: true
        command = new CreateUser attributes

      it 'has same #email', -> expect(command.email).to.equal attributes.email

      it 'has same #password', ->
        expect(command.password).to.equal attributes.password

      it 'has same #confirmPassword', ->
        expect(command.confirmPassword).to.equal attributes.confirmPassword

      it 'has same #confirmed', ->
        expect(command.confirmed).to.equal attributes.confirmed

    describe '#validate', ->
      errors = null

      describe 'no errors', ->

        before ->
          command = new CreateUser
            email: email
            password: password
            confirmPassword: password
          errors = command.validate()

        it 'returns nothing', -> expect(errors).to.be.undefined

      describe 'errors', ->

        describe 'everything missing', ->

          before ->
            command = new CreateUser
            errors = command.validate()

          it 'returns email error', ->
            expect(errors).to.have.property 'email'
            expect(_(errors.email).first()).to.equal 'Email is required.'

          it 'returns password error', ->
            expect(errors).to.have.property 'password'
            expect(_(errors.password).first()).to.equal 'Password is required.'

          it 'returns confirm password error', ->
            expect(errors).to.have.property 'confirmPassword'
            expect(_(errors.confirmPassword).first())
              .to.equal 'Confirm password is required.'

        describe 'invalid email format', ->

          before ->
            command = new CreateUser
              email: 'foo-bar'
              password: password
              confirmPassword: password
            errors = command.validate()
            
          it 'returns email error', ->
            expect(errors).to.have.property 'email'
            expect(_(errors.email).first()).to.equal 'Invalid email format.'

        describe 'incorrect password length', ->

          describe 'less than minimum length', ->

            before ->
              command = new CreateUser
                email: email
                password: repeatString 5
                confirmPassword: repeatString 5
              errors = command.validate()
              
            it 'returns password error', ->
              expect(errors).to.have.property 'password'
              expect(_(errors.password).first())
                .to
                .equal 'Password length must be between 6 to 64 characters.'

          describe 'more than maximum length', ->

            before ->
              command = new CreateUser
                email: email
                password: repeatString 65
                confirmPassword: repeatString 65
              errors = command.validate()
              
            it 'returns password error', ->
              expect(errors).to.have.property 'password'
              expect(_(errors.password).first())
                .to
                .equal 'Password length must be between 6 to 64 characters.'

        describe 'confirmPassword does not match password', ->

          before ->
            command = new CreateUser
              email: email
              password: repeatString 6, 'x'
              confirmPassword: repeatString 6, 'y'
            errors = command.validate()
            
          it 'returns confirm password error', ->
            expect(errors).to.have.property 'confirmPassword'
            expect(_(errors.confirmPassword).first())
              .to
              .equal 'Password and confirmation password do not match.'
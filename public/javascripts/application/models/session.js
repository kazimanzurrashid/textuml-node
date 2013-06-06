var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function(require) {
  var Backbone, Session, Validation, _, _ref;
  _ = require('underscore');
  Backbone = require('backbone');
  Validation = require('./validation');
  return Session = (function(_super) {
    __extends(Session, _super);

    function Session() {
      _ref = Session.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Session.prototype.url = '/sessions';

    Session.prototype.defaults = function() {
      return {
        email: null,
        password: null,
        rememberMe: false
      };
    };

    Session.prototype.validate = function(attributes) {
      var errors;
      errors = {};
      if (!attributes.email) {
        Validation.addError(errors, 'email', 'Email is required.');
      }
      if (!attributes.password) {
        Validation.addError(errors, 'password', 'Password is required.');
      }
      if (_(errors).isEmpty()) {
        return void 0;
      } else {
        return errors;
      }
    };

    return Session;

  })(Backbone.Model);
});

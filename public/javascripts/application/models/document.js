var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function(require) {
  var Backbone, Document, Validation, _, _ref;
  _ = require('underscore');
  Backbone = require('backbone');
  Validation = require('./validation');
  return Document = (function(_super) {
    __extends(Document, _super);

    function Document() {
      _ref = Document.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Document.prototype.urlRoot = '/documents';

    Document.prototype.defaults = function() {
      return {
        title: null,
        content: null,
        createdAt: null,
        updatedAt: null
      };
    };

    Document.prototype.validate = function(attributes) {
      var errors;
      errors = {};
      if (!attributes.title) {
        Validation.addError(errors, 'title', 'Title is required.');
      }
      if (_(errors).isEmpty()) {
        return void 0;
      } else {
        return errors;
      }
    };

    return Document;

  })(Backbone.Model);
});

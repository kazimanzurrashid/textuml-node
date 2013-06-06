var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function(require) {
  var $, Backbone, DocumentListItemView, Helpers, _, _ref;
  $ = require('jquery');
  _ = require('underscore');
  Backbone = require('backbone');
  Helpers = require('./helpers');
  return DocumentListItemView = (function(_super) {
    __extends(DocumentListItemView, _super);

    function DocumentListItemView() {
      _ref = DocumentListItemView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    DocumentListItemView.prototype.tagName = 'li';

    DocumentListItemView.prototype.events = {
      'dblclick .display span': 'onEdit',
      'click [data-command="delete"]': 'onDestroy',
      'keydown input[type="text"]': 'onUpdateOrCancel',
      'blur input[type="text"]': 'onCancel'
    };

    DocumentListItemView.prototype.initialize = function(options) {
      this.template = options.template;
      this.listenTo(this.model, 'change', this.render);
      return this.listenTo(this.model, 'remove destroy', this.remove);
    };

    DocumentListItemView.prototype.render = function() {
      var attributes;
      attributes = _(this.model.toJSON()).extend({
        lastUpdatedInRelativeTime: function() {
          return Helpers.formatAsRelativeTime(this.updatedAt);
        },
        lastUpdatedInHumanizeTime: function() {
          return Helpers.formatAsHumanizeTime(this.updatedAt);
        }
      });
      this.$el.html(this.template(attributes));
      return this;
    };

    DocumentListItemView.prototype.remove = function(notify) {
      var _this = this;
      if (notify == null) {
        notify = true;
      }
      if (!notify) {
        return DocumentListItemView.__super__.remove.apply(this, arguments);
      }
      this.trigger('removing');
      this.$el.fadeOut(function() {
        return DocumentListItemView.__super__.remove.apply(_this, arguments);
      });
      return this;
    };

    DocumentListItemView.prototype.showDisplay = function() {
      this.$('.edit').hide();
      return this.$('.display').show();
    };

    DocumentListItemView.prototype.showEdit = function() {
      this.$('.display').hide();
      return this.$('.edit').show().find('input[type="text"]').val(this.model.get('title')).select().focus();
    };

    DocumentListItemView.prototype.onEdit = function(e) {
      e.preventDefault();
      e.stopPropagation();
      return this.showEdit();
    };

    DocumentListItemView.prototype.onCancel = function(e) {
      e.preventDefault();
      e.stopPropagation();
      return this.showDisplay();
    };

    DocumentListItemView.prototype.onUpdateOrCancel = function(e) {
      var title;
      e.stopPropagation();
      if (e.which === 13) {
        e.preventDefault();
        title = $(e.currentTarget).val();
        if (title && title !== this.model.get('title')) {
          this.model.save({
            title: title
          });
        }
        return this.showDisplay();
      } else if (e.which === 27) {
        e.preventDefault();
        return this.showDisplay();
      } else {
        return true;
      }
    };

    DocumentListItemView.prototype.onDestroy = function(e) {
      var _this = this;
      e.preventDefault();
      e.stopPropagation();
      return $.confirm({
        prompt: 'Are you sure you want to delete ' + ("<strong>" + (this.model.get('title')) + "</strong>?"),
        ok: function() {
          return _this.model.destroy();
        }
      });
    };

    return DocumentListItemView;

  })(Backbone.View);
});

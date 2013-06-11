define(function(require) {
  var $, moment, _;
  $ = require('jquery');
  _ = require('underscore');
  moment = require('moment');
  require('form');
  return {
    formatAsRelativeTime: function(date) {
      return moment(date).fromNow();
    },
    formatAsHumanizeTime: function(date) {
      return moment(date).format('dddd, MMMM Do YYYY, h:mm a');
    },
    hasModelErrors: function(jqxhr) {
      return jqxhr.status === 400;
    },
    getModelErrors: function(jqxhr) {
      var e, response;
      response = null;
      try {
        response = $.parseJSON(jqxhr.responseText);
      } catch (_error) {
        e = _error;
        response = null;
      }
      return response;
    },
    subscribeModelInvalidEvent: function(model, element) {
      return model.once('invalid', function() {
        return element.showFieldErrors({
          errors: model.validationError
        });
      });
    }
  };
});

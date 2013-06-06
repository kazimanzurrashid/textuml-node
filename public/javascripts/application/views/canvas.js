var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function(require) {
  var $, Backbone, CanvasView, Renderer, events, _ref;
  $ = require('jquery');
  Backbone = require('backbone');
  Renderer = require('../uml/drawing/sequence/renderer');
  events = require('../events');
  require('flashbar');
  return CanvasView = (function(_super) {
    __extends(CanvasView, _super);

    function CanvasView() {
      _ref = CanvasView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    CanvasView.prototype.el = '#canvas-container';

    CanvasView.prototype.rendererType = Renderer;

    CanvasView.prototype.initialize = function(options) {
      this.context = options.context;
      this.renderer = new this.rendererType;
      this.listenTo(events, 'parseStarted', this.onParseStarted);
      this.listenTo(events, 'parseCompleted', this.onParseCompleted);
      return this.listenTo(events, 'exportDocument', this.onExportDocument);
    };

    CanvasView.prototype.onParseStarted = function() {
      return this.renderer.reset();
    };

    CanvasView.prototype.onParseCompleted = function(e) {
      var title, _ref1;
      title = null;
      if (e != null ? e.diagram : void 0) {
        title = (_ref1 = e.diagram.title) != null ? _ref1.text : void 0;
        this.renderer.render(e.diagram);
      }
      return this.context.setCurrentDocumentTitle(title);
    };

    CanvasView.prototype.onExportDocument = function() {
      var data, exception;
      try {
        data = this.renderer.serialize();
        return events.trigger('documentExported', {
          data: data
        });
      } catch (_error) {
        exception = _error;
        return $.showErrorbar(exception.message);
      }
    };

    return CanvasView;

  })(Backbone.View);
});

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

define(function(require) {
  var $, Backbone, Document, Documents, SortOrder, _;
  $ = require('jquery');
  _ = require('underscore');
  Backbone = require('backbone');
  SortOrder = require('./sortorder');
  Document = require('./document');
  return Documents = (function(_super) {
    __extends(Documents, _super);

    Documents.prototype.defaultSortAttribute = 'updatedAt';

    Documents.prototype.defaultSortOrder = SortOrder.descending;

    Documents.prototype.countAttribute = 'count';

    Documents.prototype.resultAttribute = 'data';

    Documents.prototype.defaultPageSize = 25;

    Documents.prototype.filter = null;

    Documents.prototype.url = '/documents';

    Documents.prototype.model = Document;

    function Documents() {
      Documents.__super__.constructor.apply(this, arguments);
      this.resetSorting();
      this.resetPaging();
    }

    Documents.prototype.parse = function(resp) {
      this.setCounts(resp[this.countAttribute]);
      return resp[this.resultAttribute];
    };

    Documents.prototype.fetch = function(options) {
      var orderBy, query;
      if (options == null) {
        options = {};
      }
      query = {
        top: this.pageSize
      };
      if (this.pageIndex) {
        query.skip = this.pageSize * this.pageIndex;
      }
      if (this.sortAttribute) {
        orderBy = this.sortAttribute;
        if (this.sortOrder === SortOrder.ascending) {
          orderBy += ' asc';
        } else if (this.sortOrder === SortOrder.descending) {
          orderBy += ' desc';
        }
        query.orderBy = orderBy;
      }
      if (this.filter) {
        query.filter = this.filter;
      }
      options.url = (_(this).result('url')) + '?' + $.param(query);
      return Documents.__super__.fetch.call(this, options);
    };

    Documents.prototype.fetchOne = function(id, options) {
      var document, success,
        _this = this;
      options = _(options).defaults({
        success: function() {},
        error: function() {}
      });
      document = this.get(id);
      if (document) {
        return _(function() {
          return options.success(document);
        }).defer();
      } else {
        document = new Document;
        document.id = id;
        success = options.success;
        options.success = function() {
          _this.add(document);
          return success(document);
        };
        return document.fetch(options);
      }
    };

    Documents.prototype.setCounts = function(count) {
      this.totalCount = count;
      this.pageCount = Math.ceil(count / this.pageSize);
      return this;
    };

    Documents.prototype.resetSorting = function() {
      this.sortAttribute = this.defaultSortAttribute;
      return this.sortOrder = this.defaultSortOrder;
    };

    Documents.prototype.resetPaging = function() {
      this.pageSize = this.defaultPageSize;
      this.pageIndex = 0;
      this.pageCount = 0;
      return this.totalCount = 0;
    };

    return Documents;

  })(Backbone.Collection);
});

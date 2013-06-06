define(function(require) {
  var Context, Documents, Sharing;
  Sharing = require('./sharing');
  Documents = require('./models/documents');
  return Context = (function() {
    Context.prototype.documentsType = Documents;

    function Context(options) {
      if (options == null) {
        options = {};
      }
      this.resetCurrentDocument();
      this.documents = new this.documentsType;
      if (options.userSignedIn) {
        if (options.documents) {
          this.documents.reset(options.documents.data);
          this.documents.setCounts(options.documents.count);
        }
        this.userSignedIn(false);
      }
    }

    Context.prototype.isUserSignedIn = function() {
      return this.signedIn;
    };

    Context.prototype.userSignedIn = function(fetchDocuments) {
      if (fetchDocuments == null) {
        fetchDocuments = true;
      }
      this.signedIn = true;
      Sharing.start();
      if (fetchDocuments) {
        return this.documents.fetch({
          reset: true
        });
      }
    };

    Context.prototype.userSignedOut = function() {
      this.signedIn = false;
      Sharing.stop();
      this.documents.reset();
      return this.resetCurrentDocument();
    };

    Context.prototype.resetCurrentDocument = function() {
      this.id = null;
      this.title = null;
      return this.content = null;
    };

    Context.prototype.setCurrentDocument = function(id, callback) {
      var _this = this;
      return this.documents.fetchOne(id, {
        success: function(document) {
          var attributes;
          attributes = document.toJSON();
          _this.id = attributes.id;
          _this.title = attributes.title;
          _this.content = attributes.content;
          return typeof callback === "function" ? callback(document) : void 0;
        },
        error: function() {
          _this.resetCurrentDocument();
          return typeof callback === "function" ? callback() : void 0;
        }
      });
    };

    Context.prototype.getCurrentDocumentId = function() {
      return this.id;
    };

    Context.prototype.getCurrentDocumentTitle = function() {
      return this.title || '';
    };

    Context.prototype.setCurrentDocumentTitle = function(value) {
      if (!value) {
        value = null;
      }
      return this.title = value;
    };

    Context.prototype.getCurrentDocumentContent = function() {
      return this.content || '';
    };

    Context.prototype.setCurrentDocumentContent = function(value) {
      if (!value) {
        value = null;
      }
      return this.content = value;
    };

    Context.prototype.isCurrentDocumentNew = function() {
      return !this.id;
    };

    Context.prototype.isCurrentDocumentDirty = function() {
      var document;
      if (this.isCurrentDocumentNew()) {
        return this.content;
      }
      document = this.documents.get(this.id);
      return this.content !== document.get('content');
    };

    Context.prototype.saveCurrentDocument = function(callback) {
      var attributes, document,
        _this = this;
      attributes = {
        content: this.content
      };
      if (this.isCurrentDocumentNew()) {
        attributes.title = this.title;
        return this.documents.create(attributes, {
          wait: true,
          success: function(doc) {
            _this.id = doc.id;
            return typeof callback === "function" ? callback() : void 0;
          }
        });
      } else {
        document = this.documents.get(this.id);
        return document.save(attributes, {
          success: function() {
            return typeof callback === "function" ? callback() : void 0;
          }
        });
      }
    };

    Context.prototype.getNewDocumentTitle = function() {
      var count, title;
      title = this.title;
      if (!title) {
        count = this.documents.length + 1;
        title = "New document " + count;
      }
      return title;
    };

    return Context;

  })();
});

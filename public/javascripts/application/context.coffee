define (require) ->
  Sharing       = require './sharing'
  Documents     = require './models/documents'

  class Context
    documentsType: Documents

    constructor: (options = {}) ->
      @resetCurrentDocument()
      @documents = new @documentsType
      if options.userSignedIn
        if options.documents
          @documents.reset options.documents.data
          @documents.setCounts options.documents.count
        @userSignedIn false

    isUserSignedIn: -> @signedIn

    userSignedIn: (fetchDocuments = true) ->
      @signedIn = true
      Sharing.start()
      @documents.fetch reset: true if fetchDocuments

    userSignedOut: ->
      @signedIn = false
      Sharing.stop()
      @documents.reset()
      @resetCurrentDocument()

    resetCurrentDocument: ->
      @id         = null
      @title      = null
      @content    = null

    setCurrentDocument: (id, callback) ->
      @documents.fetchOne id,
        success: (document) =>
          attributes  = document.toJSON()
          @id         = attributes.id
          @title      = attributes.title
          @content    = attributes.content
          callback? document
        error: =>
          @resetCurrentDocument()
          callback?()

    getCurrentDocumentId: -> @id

    getCurrentDocumentTitle: -> @title or ''

    setCurrentDocumentTitle: (value) ->
      value = null unless value
      @title = value

    getCurrentDocumentContent: -> @content or ''

    setCurrentDocumentContent: (value) ->
      value = null unless value
      @content = value

    isCurrentDocumentNew: -> not @id

    isCurrentDocumentDirty: ->
      return @content if @isCurrentDocumentNew()

      document = @documents.get @id
      @content isnt document.get 'content'

    saveCurrentDocument: (callback) ->
      attributes = content: @content

      if @isCurrentDocumentNew()
        attributes.title = @title
        @documents.create attributes,
          wait: true
          success: (doc) =>
            @id = doc.id
            callback?()
      else
        document = @documents.get @id
        document.save attributes, success: -> callback?()

    getNewDocumentTitle: ->
      title = @title
      unless title
        count = @documents.length + 1
        title = "New document #{count}"
      title

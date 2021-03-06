define (require)->
  _     = require 'underscore'
  trim  = require('./helpers').trim

  RightArrow =
    asyncDash: '-->>'
    syncDash: '-->'
    asyncLine: '->>'
    syncLine: '->'

  LeftArrow =
    asyncDash: '<<--'
    syncDash: '<--'
    asyncLine: '<<-'
    syncLine: '<-'

  RightArrows = _(RightArrow).values()

  LeftArrows = _(LeftArrow).values()

  LineArrows =  [
    RightArrow.asyncLine,
    RightArrow.syncLine,
    LeftArrow.asyncLine,
    LeftArrow.syncLine
  ]

  DashArrows =  [
    RightArrow.asyncDash,
    RightArrow.syncDash,
    LeftArrow.asyncDash,
    LeftArrow.syncDash
  ]

  SyncArrows = [
    RightArrow.syncDash,
    RightArrow.syncLine,
    LeftArrow.syncDash,
    LeftArrow.syncLine
  ]

  AsyncArrows = [
    RightArrow.asyncDash,
    RightArrow.asyncLine,
    LeftArrow.asyncDash,
    LeftArrow.asyncLine
  ]

  AllArrows = _(RightArrows).union LeftArrows

  Regex = new RegExp("^[\\s|\\t]*(\\w.*)\\s+(#{AllArrows.join '|'})\\s+(\\w.*)\\s*:\\s*(\\w.*)", 'i')

  class Message
    handles: (context) ->
      match = context.line.match Regex
      return false unless match
      arrow = trim match[2]

      if _(RightArrows).contains arrow
        sender = context.findOrCreateParticipant trim(match[1])
        receiver = context.findOrCreateParticipant trim(match[3])
      else if _(LeftArrows).contains arrow
        receiver = context.findOrCreateParticipant trim(match[1])
        sender = context.findOrCreateParticipant trim(match[3])
      else
        errorMessage = "Error on line #{context.getLineNumber()}, " +
          "unrecognized arrow \"#{arrow}\"."
        throw new Error errorMessage

      async = if _(AsyncArrows).contains arrow
          true
        else if _(SyncArrows).contains arrow
          false
        else
          errorMessage = "Error on line #{context.getLineNumber()}, " +
            "unrecognized arrow \"#{arrow}\"."
          throw new Error errorMessage

      callReturn = if _(DashArrows).contains arrow
          true
        else if _(LineArrows).contains arrow
          false
        else
          errorMessage = "Error on line #{context.getLineNumber()}, " +
            "unrecognized arrow \"#{arrow}\"."
          throw new Error errorMessage

      name = trim match[4]

      context.addMessage sender
      , receiver
      , name
      , async
      , callReturn

      true

Template.matchlist.matches = ->
  return Matches.find({}, {sort:{date:-1}})

Template.matchlist.amIEditing = ->
  draft = Drafts.findOne({matchId:@_id, userId:Meteor.userId(), connectionId:Session.get('connId')})
  return draft?

Template.matchitem.underEdit = ->
  return Drafts.findOne({matchId:@_id})?

Template.matchitem.result = ->
  if this.win == "F"
    "FLATLINED"
  else if this.win == "M"
    "MILLED"

Template.winnerWrapper.sideWon = ->
  if this.side == "corp"
    this.match.corporation().won
  else if this.side == "runner"
    this.match.runner().won

Template.matchdetail.matchStatusAttr = (side) ->
  if side == "corp" 
    "class": 
      if this.match.corporation().won
        "label label-success" 
      else if this.match.win == "M" 
        "label label-danger"
      else
        "label"
  else if side == "runner"
    "class": 
      if this.match.runner().won
        "label label-success" 
      else if this.match.win == "F"
        "label label-danger"
      else
        "label"

Template.matchdetail.matchStatusLabel = (side) ->
  if side == "corp"
    this.match.corporation().status
  else if side == "runner"
    this.match.runner().status

gatherNames = (cursor, playerid) ->
  i = 1
  playerndx = 0
  list = cursor.map (p) ->
    playerndx = i if p._id == playerid
    {value: i++, text: p.name, fieldValue:p._id}
  {source: list, value: playerndx}

gatherIdents = (cursor, id)->
  i = 1
  corpndx = 0
  list = cursor.map (f)->
    corpndx = i if f._id == id
    {value: i++, text: identityName(f._id), fieldValue: f._id}
  {source:list, value: corpndx}

gatherWin = (match) ->
  list = [
    {value:1, text:"Agenda", fieldValue:"A"}
    {value:2, text:"Flatlined", fieldValue:"F"}
    {value:3, text:"Milled", fieldValue:"M"}
  ]

  { source: list, value: ($.grep list, (o)->o.fieldValue == match.win)[0].value }

Template.editmatchitem.rendered = ->
  c = Players.find()
  corp_names = gatherNames c, this.data.corp_player
  c.rewind()
  runner_names = gatherNames c, this.data.runner_player

  corp_idents = gatherIdents Identity.find({side:'C'}), this.data.corp_identity
  runner_idents = gatherIdents Identity.find({side:'R'}), this.data.runner_identity
  wins = gatherWin this.data

  updateFactionClass = (selector, newfaction) ->
      selector.removeClass (index, css) ->
        (css.match(/(^|\s)faction-\S/g) || []).join(' ')
      selector.addClass "faction-#{newfaction}"

  baseOpts = 
    type: "select"
    showbuttons: false 
    inputclass: "input-sm"
    pk: @data._id
    error: (error) -> error

  makeEditable = (selector, field, data, success) ->
    $(selector).editable $.extend {}, baseOpts, 
      source: data.source
      value: data.value
      success: success
      url: (options) ->
        d = new $.Deferred
        elem = $.grep data.source, (o) -> o.value == parseInt(options.value)
        if elem.length
          Meteor.call 'update_match', options.pk, field, elem[0].fieldValue, (error, result) ->
            if error? then d.reject error.reason else d.resolve {'pk':options.pk, 'result':result}
        else
          d.reject "Couldn't parse selection"

        d.promise()

  makeEditable '#select-corp-player', 'corp_player', corp_names
  makeEditable '#select-runner-player', 'runner_player', runner_names
  makeEditable '#select-corp-ident', 'corp_identity', corp_idents, (value) -> updateFactionClass($('#select-corp-ident'), value.result.faction)
  makeEditable '#select-runner-ident', 'runner_identity', runner_idents, (value) -> updateFactionClass($('#select-runner-ident'), value.result.faction)
  makeEditable '#select-win', 'win', wins

  $('#select-corp-points').editable
    type: "number"
    value: this.data.corp_agenda
    min: 0
    clear: false
    setcursor: false
    inputclass: "input-sm"
    pk: @data._id
    url: (options) ->
      d = new $.Deferred()
      Meteor.call 'update_match', options.pk, 'corp_agenda', parseInt(options.value), (error, result) ->
        if error? then d.reject error.reason else d.resolve options.pk
      d.promise()

  $('#select-runner-points').editable
    type: "number"
    value: this.data.runner_agenda
    min: 0
    clear: false
    setcursor: false
    inputclass: "input-sm"
    pk: @data._id
    url: (options) ->
      d = new $.Deferred()
      Meteor.call 'update_match', options.pk, 'runner_agenda',  parseInt(options.value), (error, result) ->
        if error? then d.reject error.reason else d.resolve options.pk
      d.promise()

  $('#select-date').editable
    type: "date"
    placement: "bottom"
    value: moment(this.data.date).format('YYYY-MM-DD')
    viewformat: 'MM d, yyyy'
    pk: @data._id
    url: (options) ->
      d = new $.Deferred()
      Meteor.call 'update_match', options.pk, 'date', moment(options.value).unix()*1000, (error, result) ->
        if error? then d.reject error.reason else d.resolve options.pk
      d.promise()

Template.matchitem.events =
  'click .edit-row': (e) ->
    e.preventDefault()
    Meteor.call 'start_edit', @_id

    Session.set('matchid', @_id)
    Session.set('match_obj', @)
    $('.match-row').fadeTo("fast", 0.2)

Template.editmatchitem.events =
  'click .save-row': (e) ->
    e.preventDefault()
    Meteor.call 'save_edit', @_id
    Session.set('matchid', null)
    Session.set('match_obj', null)
    $('.match-row').fadeTo("fast", 1)
  'click .cancel-row': (e) ->
    e.preventDefault()
    Meteor.call 'cancel_edit', @_id
    Session.set('matchid', null)
    Session.set('match_obj', null)
    $('.match-row').fadeTo("fast", 1)

UI.registerHelper 'format_date', (date) ->
  moment(date).format('MMMM D, YYYY')

UI.registerHelper 'player_name', (player) ->
  Players.findOne({_id:player}).name

UI.registerHelper 'session', (key) ->
  Session.get(key)

UI.registerHelper 'sessionEquals', (key, value) ->
  Session.equals(key, value)

factionColor = (identity) ->
  ident = Identity.findOne {_id:identity}
  "class": "faction-#{ident.faction}"

UI.registerHelper 'factionColor', factionColor

identityName = (identity) ->
  ident = Identity.findOne {_id:identity}
  "#{factionFullName ident.faction}: #{ident.name}"

UI.registerHelper 'identityName', identityName


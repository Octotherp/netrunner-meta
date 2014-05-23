Template.matchlist.matches = ->
  return Matches.find({}, {sort:{date:-1}})

Template.matchlist.amIEditing = ->
  return Drafts.findOne({matchId:@_id, userId:Meteor.userId()})?

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
    {value: i++, text: p.name, doc:p}
  {source: list, value: playerndx}

gatherIdents = (cursor, id)->
  i = 1
  corpndx = 0
  list = cursor.map (f)->
    corpndx = i if f._id == id
    {value: i++, text: identityName(f._id), doc: f}
  {source:list, value: corpndx}

gatherWin = (match) ->
  list = [
    {value:1, text:"Agenda", win:"A"}
    {value:2, text:"Flatlined", win:"F"}
    {value:3, text:"Milled", win:"M"}
  ]

  { source: list, value: ($.grep list, (o)->o.win == match.win)[0].value }

updateSessionObj = (id, key, value) ->
  # console.log Session.get id
  (o = Session.get(id))[key] = value
  Session.set(id, o)
  # console.log Session.get id

updateMatch = (options) ->
  d = new $.Deferred
  elem = $.grep options.source, (o) -> o.value == parseInt(options.value)
  if elem.length
    Meteor.call options.func, options.pk, options.field, elem[0].doc._id, (error, result) ->
      if error? then d.reject error.reason else d.resolve options.pk
  else
    d.reject "Couldn't parse selection"

  d.promise()

Template.editmatchitem.rendered = ->
  c = Players.find()
  corp_names = gatherNames c, this.data.corp_player
  c.rewind()
  runner_names = gatherNames c, this.data.runner_player

  corp_idents = gatherIdents Identity.find({side:'C'}), this.data.corp_identity
  runner_idents = gatherIdents Identity.find(), this.data.runner_identity
  wins = gatherWin this.data

  $('#select-corp-player').editable
    type: "select"
    showbuttons: false 
    inputclass: "input-sm"
    source: corp_names.source
    value: corp_names.value
    url: updateMatch
    pk: @data._id
    params: 
      func: 'update_player'
      field: 'corp_player'
      source: corp_names.source
    error: (error) ->
      error
    success: (pk) ->
      console.log "got a response for #{pk}"
    # success: (response, newValue) ->
    #   thisThing = this
    #   elem = $.grep corp_names.source, (o) -> o.value == parseInt(newValue)
    #   if elem.length then result = Meteor.call 'update_player', 'corp_player', elem[0].doc._id, (error, result) ->
    #     if error? then config.error.call(thisThing, error.reasons)

  $('#select-runner-player').editable
    type: "select"
    inputclass: "input-sm"
    showbuttons: false 
    source: runner_names.source
    value: runner_names.value
    success: (response, newValue) ->
      elem = $.grep runner_names.source, (o) -> o.value == parseInt(newValue)
      if elem.length then updateSessionObj 'match_obj', 'runner_player', elem[0].doc._id

  $('#select-corp-ident').editable
    type: "select"
    source: corp_idents.source
    value: corp_idents.value
    showbuttons: false 
    success: (response, newValue) ->
      elem = $.grep corp_idents.source, (o) -> o.value == parseInt(newValue)
      if elem.length
        updateSessionObj 'match_obj', 'corp_identity', elem[0].doc._id
        $(this).removeClass (index, css) ->
          (css.match(/(^|\s)faction-\S/g) || []).join(' ')
        $(this).addClass "faction-#{elem[0].doc.faction}"

  $('#select-runner-ident').editable
    type: "select"
    source: runner_idents.source
    value: runner_idents.value
    showbuttons: false 
    success: (response, newValue) ->
      elem = $.grep runner_idents.source, (o) -> o.value == parseInt(newValue)
      if elem.length
        updateSessionObj 'match_obj', 'runner_identity', elem[0].doc._id
        $(this).removeClass (index, css) ->
          (css.match(/(^|\s)faction-\S/g) || []).join(' ')
        $(this).addClass "faction-#{elem[0].doc.faction}"

  $('#select-win').editable
    type: "select"
    source: wins.source
    value: wins.value
    showbuttons: false 
    inputclass: "input-sm"
    success: (response, newValue) ->
      elem = $.grep wins.source, (o) -> o.value == parseInt(newValue)
      if elem.length then updateSessionObj 'match_obj', 'win', elem[0].win

  $('#select-corp-points').editable
    type: "number"
    value: this.data.corp_agenda
    min: 0
    clear: false
    setcursor: false
    inputclass: "input-sm"
    success: (response, newValue) ->
      updateSessionObj 'match_obj', 'corp_agenda', parseInt(newValue)

  $('#select-runner-points').editable
    type: "number"
    value: this.data.runner_agenda
    min: 0
    clear: false
    setcursor: false
    inputclass: "input-sm"
    success: (response, newValue) ->
      updateSessionObj 'match_obj', 'runner_agenda', parseInt(newValue)

  $('#select-date').editable
    type: "date"
    placement: "bottom"
    value: moment(this.data.date).format('YYYY-MM-DD')
    viewformat: 'MM d, yyyy'
    success: (response, newValue) ->
      m = moment(newValue).add('m', newValue.getTimezoneOffset() )
      updateSessionObj 'match_obj', 'date', m.unix()

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


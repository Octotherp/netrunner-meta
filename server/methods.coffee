Meteor.methods
  update_match: (matchId, field, value) ->
    check(matchId, String)
    check(field, String)
    set = {}
    set["doc.#{field}"] = value

    if field == 'corp_player' or field == 'runner_player'
      check(value, String)
      p = Players.findOne({_id:value})
      if !p? then Meteor.Error(403, "Player id #{value} not found")

      updated = Drafts.update({matchId:matchId, connectionId:@connection.id}, {$set:set})
    else if field == 'corp_identity' or field == 'runner_identity'
      check(value, String)
      i = Identity.findOne({_id:value})
      if !i? then Meteor.Error(403, "Identity id #{value} not found")
      updated = Drafts.update({matchId:matchId, connectionId:@connection.id}, {$set:set})
      console.log i.name
      return { 'faction': i.faction }
    else if field == 'win'
      check(value, String)
      if value == 'A' or value == 'F' or value == 'M'
        updated = Drafts.update({matchId:matchId, connectionId:@connection.id}, {$set:set})
      else 
        Meteor.Error(403, "Win type #{value}")
    else if field == 'corp_agenda' or field == 'runner_agenda'
      check(value, Number)
      updated = Drafts.update({matchId:matchId, connectionId:@connection.id}, {$set:set})
    else if field == 'date'
      check(value, Number)
      updated = Drafts.update({matchId:matchId, connectionId:@connection.id}, {$set:set})
    else
      Meteor.Error(403, "trying to update #{field}")

  start_edit: (matchId) ->
    check(matchId, String)
    m = Matches.findOne({_id:matchId})
    if !m? then Meteor.Error(403, "Match Not Found")

    Drafts.insert
      userId: @userId
      connectionId: @connection.id
      matchId: matchId
      doc: m

  save_edit: (matchId) ->
    check(matchId, String)
    m = Matches.findOne({_id:matchId})
    if !m? then Meteor.Error(403, "Match Not Found")
    draft = Drafts.findOne({matchId:matchId, connectionId:@connection.id})
    Drafts.remove({matchId:matchId, connectionId:@connection.id})
    if !draft? then Meteor.Error(403, "Match Not Found")
    Matches.update({_id:draft.matchId}, draft.doc)

  cancel_edit: (matchId) ->
    check(matchId, String)
    m = Matches.findOne({_id:matchId})
    if !m? then Meteor.Error(403, "Match Not Found")
    Drafts.remove({matchId:matchId, connectionId:@connection.id})

  my_connectionId: ->
    return @connection.id
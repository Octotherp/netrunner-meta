Meteor.methods
  update_player: (matchId, field, value) ->
    check(matchId, String)
    check(field, String)
    check(value, String)

    p = Players.findOne({_id:value})
    if !p? then Meteor.Error(403, "Player id #{value} not found")

    set = {}
    set["doc.#{field}"] = value
    updated = Drafts.update({matchId:matchId, connectionId:@connection.id}, {$set:set})

  start_edit: (matchId) ->
    check(matchId, String)
    m = Matches.findOne({_id:matchId})
    if !m? then Meteor.Error(403, "Match Not Found")

    Drafts.insert
      userId: @userId
      connectionId: @connection.id
      matchId: matchId
      doc: m

  save_edit: (matchID) ->
    check(matchID, String)
    m = Matches.findOne({_id:matchID})
    if !m? then Meteor.Error(403, "Match Not Found")
    draft = Drafts.findOne({matchId:matchID, connectionId:@connection.id})
    Drafts.remove({matchId:matchID, connectionId:@connection.id})
    if !draft? then Meteor.Error(403, "Match Not Found")

  cancel_edit: (matchID) ->
    check(matchID, String)
    m = Matches.findOne({_id:matchID})
    if !m? then Meteor.Error(403, "Match Not Found")
    Drafts.remove({matchId:matchID, connectionId:@connection.id})
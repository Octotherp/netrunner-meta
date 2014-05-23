Template.player.players = ->
  return Players.find()

Template.player.thePlayer = ->
  playerid = Session.get('playerid')
  if playerid?
    return parseInt playerid
  return null
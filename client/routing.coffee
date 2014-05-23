AppRouter = Backbone.Router.extend
  routes:
    "": "home"
    "players": "player"
    "player/:player": "player"
    "matches": "match"
    "tournament": "tournament"
  home: ->
    Session.set('page', 'home')
  player: (player) ->
    Session.set('page', 'player')
    Session.set('playerid', player)
  match: ->
    Session.set('page', 'match')
  tournament: ->
    Session.set('page', 'tournament')

Router = new AppRouter
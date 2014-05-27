Template.navbar.headers = ->
  return [
    {
      'url':'players'
      'page': 'player'
      'name':'Players'
    },
    {
      'url':'matches'
      'page': 'match'
      'name':'Matches'
    },
    {
      'url':'tournament'
      'page': 'tournament'
      'name':'Tournament'
    },
  ]

Template.navbar.headerActive = -> 
  if Session.equals('page', this.page)
    return {'class':'active'}

Template.ifPageIs.page_is = (value) ->
  Session.equals( 'page', value ) 

Template.navbar.events =
  'click .header-link': (e) ->
    e.preventDefault()
    Session.set('page', this.page)


Meteor.subscribe 'players'
Meteor.subscribe 'identities'
Meteor.subscribe 'matches'
Meteor.subscribe 'drafts'

Meteor.startup ->
  Meteor.call 'my_connectionId', (error, connId) ->
    Session.set('connId', connId)
  Backbone.history.start {pushState: true}
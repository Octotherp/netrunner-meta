# Meteor.users.find({'status.online': true }).observe
#   added: (id) ->
#     console.log "#{id} came online"
#   removed: (id) ->
#     console.log "#{id} went offline"

UserStatus.events.on 'connectionLogin', (e) ->
  Drafts.remove({userId:e.userId})
  # console.log "Login #{e.userId}, #{e.connectionId}, #{e.ipAddr}"

UserStatus.events.on 'connectionLogout', (e) ->
  # console.log "Logout #{e.userId}, #{e.connectionId}"
  # console.log "removing disconnect draft"
  Drafts.remove({userId:e.userId})

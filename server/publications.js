Meteor.publish('players', function() {
  return Players.find();
});

Meteor.publish('identities', function() {
  return Identity.find();
});

Meteor.publish('matches', function() {
  return Matches.find();
});

Meteor.publish('drafts', function() {
  // return Drafts.find();
  return Drafts.find({}, {fields:{matchId:1, userId:1, connectionId:1}});
});
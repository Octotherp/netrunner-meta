Players = new Meteor.Collection("players")
Identity = new Meteor.Collection("identity")
Drafts = new Meteor.Collection("drafts")

QuickMatch = function (doc) {
    _.extend(this, doc)
};
QuickMatch.prototype = {
    constructor: Match,
    corporation: function() {
        var p = Players.findOne({_id:this.corp_player})
        var i = Identity.findOne({_id:this.corp_identity, side:'C'})
        var w = this.win === "F" || (this.corp_agenda > this.runner_agenda && this.win !== "M")
        var s = w ? "WINNER" : this.win == "M" ? "MILLED" : " "
        return {
            "player"    : p,
            "identity"  : i,
            "points"    : this.corp_agenda,
            "won"       : w,
            "status"    : s,
        }
    },
    runner: function() {
        var p = Players.findOne({_id:this.runner_player})
        var i = Identity.findOne({_id:this.runner_identity, side:'R'})
        var w = this.win === "M" || (this.runner_agenda > this.corp_agenda && this.win !== "F")
        var s = w ? "WINNER" : this.win == "F" ? "FLATLINED" : " "
        return {
            "player"    : p,
            "identity"  : i,
            "points"    : this.runner_agenda,
            "won"       : w,
            "status"    : s,
        }
    }
}

Matches = new Meteor.Collection("matches", {
  transform: function (doc) {
    return new QuickMatch(doc);
  }
});
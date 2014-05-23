Meteor.startup ->
    if Players.find().count() == 0
        p1 = Players.insert
            name: "Alice"
        p2 = Players.insert
            name: "Bob"
        p3 = Players.insert
            name: "Carol"
        p4 = Players.insert
            name: "Danny"
    if Identity.find().count() == 0
        c1 = Identity.insert
            name: 'Engineering the Future'
            faction: 'H'
            side: 'C'
        c2 = Identity.insert
            name: 'Building a Better World'
            faction: 'W'
            side: 'C'
        c3 = Identity.insert
            name: 'Making News'
            faction: 'N'
            side: 'C'
        c4 = Identity.insert
            name: 'Personal Evolution'
            faction: 'J'
            side: 'C'
        r1 = Identity.insert
            name: 'Noise'
            faction: 'A'
            side: 'R'
        r2 = Identity.insert
            name: 'Kate "Mac" McCafrey'
            faction: 'S'
            side: 'R'
        r3 = Identity.insert
            name: 'Gabriel Santiago'
            faction: 'C'
            side: 'R'
    if Matches.find().count() == 0
        Matches.insert
            corp_player: p1
            corp_identity: c1
            corp_agenda: 7
            runner_player: p2
            runner_identity: r1
            runner_agenda: 4
            win: 'A'
            date: Date.parse("2010-10-10")
        Matches.insert
            corp_player: p3
            corp_identity: c2
            corp_agenda: 3
            runner_player: p4
            runner_identity: r2
            runner_agenda: 8
            win: 'A'
            date: Date.parse("2011-11-11")
        Matches.insert
            corp_player: p1
            corp_identity: c3
            corp_agenda: 2
            runner_player: p3
            runner_identity: r3
            runner_agenda: 3
            win: 'M'
            date: Date.parse("2012-12-12")
        Matches.insert
            corp_player: p2
            corp_identity: c1
            corp_agenda: 4
            runner_player: p4
            runner_identity: r3
            runner_agenda: 6
            win: 'F'
            date: Date.parse("2013-1-1")


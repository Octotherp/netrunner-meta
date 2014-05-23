identityLookup =
  H: "H|B"
  W: "Weyland"
  N: "NBN"
  J: "Jinteki"
  A: "Anarch"
  S: "Shaper"
  C: "Criminal"

@factionFullName = (code) ->
  return identityLookup[code]
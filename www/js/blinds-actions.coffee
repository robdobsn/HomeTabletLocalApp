GetBlindsActions = () ->
	blindsDef = 
		[
			[ "Games Room", [ ["1", "Shade 1"], ["2", "Shade 2"] ], "http://192.168.0.225/blind/"],
			[ "Grace Bath", [ ["1", "Blinds"] ], "http://192.168.0.82/blind/" ],
			[ "Office", [ ["1", "Rob's Shade"], ["2", "Left"], ["3", "Mid-Left"], ["4", "Mid-Right"], ["5", "Right"] ], "http://192.168.0.220/blind/"]
		]
	actionsArray = GenBlindsActions(blindsDef)

GenBlindsActions = (blindsDefs) ->
	blindsDirns = [ ["Up", "up"], ["Stop","stop"], ["Down","down"] ]
	actions = []
	for room in blindsDefs
		for win in room[1]
			for dirn in blindsDirns
				actions.push [ 0, win[1] + " " + dirn[0], room[0], room[2] + win[0] + "/" + dirn[1] + "/pulse"]
	actions

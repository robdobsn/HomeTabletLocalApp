GetBlindsActions = () ->
	blindsDef = 
		[
			[ "Games Room", [ ["1", "Shade 1"], ["2", "Shade 2"] ], "http://192.168.0.225/blind/"],
			[ "Grace Bath", [ ["1", "Shade"] ], "http://192.168.0.226/blind/" ],
			[ "Office", [ ["1", "Rob's Shade"], ["2", "Left"], ["3", "Mid-Left"], ["4", "Mid-Right"], ["5", "Right"] ], "http://192.168.0.220/blind/"]
		]
	actionsArray = GenBlindsActions(blindsDef)

GenBlindsActions = (blindsDefs) ->
	blindsDirns = [ ["Up", "up"], ["Stop","stop"], ["Down","down"] ]
	actions = []
	for room in blindsDefs
		for dirn in blindsDirns
			for win in room[1]
				actions.push { tierName: "doorBlindsTier", actionNum: 0, actionName: win[1] + " " + dirn[0], groupName: room[0], actionUrl: room[2] + win[0] + "/" + dirn[1] + "/pulse", iconName: "blinds-" + dirn[1] }
	actions

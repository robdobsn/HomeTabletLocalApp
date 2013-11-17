class VeraServer
	constructor: (@serverURL) ->
		@ACTIONS_URI = @serverURL + "/data_request?id=user_data2&output_format=xml"

	setReadyCallback: (@veraReadyCallback) ->

	getActionGroups: ->
		$.ajax @ACTIONS_URI,
			type: "GET"
			dataType: "xml"
			crossDomain: true
			success: (data, textStatus, jqXHR) =>
				@rooms = @getRooms(jqXHR.responseText)
				@scenes = @getScenes(jqXHR.responseText, @rooms)
				@scenes.sort @sortByRoomName
				@veraReadyCallback(@scenes)

	sortByRoomName: (a, b) ->
		if a[2] < b[2] then return -1
		if a[2] > b[2] then return 1
		return 0

	getMatches: (inText, re) ->
		matches = []
		text = inText
		while true
			grpInfo = re.exec(text)
			if grpInfo is null then break
			pos = text.search re
			if pos is -1 then break
			text = text.substring(pos+grpInfo[0].length)			
			matches[matches.length] = grpInfo[1]
		matches

	getScenes: (respText, rooms) ->
		scenes = []
		matchScene = ///
			<scene\b(.*?)>
			///
		strMatches = @getMatches(respText, matchScene)
		for mtch in strMatches
			@addScene(scenes, mtch, rooms)
		scenes

	addScene: (scenes, tagBody, rooms) ->
		re1 = /name="(.*?)"/
		grp1 = re1.exec(tagBody)
		if grp1 is null then return
		re2 = /id="(.*?)"/
		grp2 = re2.exec(tagBody)
		if grp2 is null then return
		re3 = /room="(.*?)"/
		grp3 = re3.exec(tagBody)
		if grp3 is null then return
		room = ""
		if grp3[1] of rooms
			room = rooms[grp3[1]]
		sceneCmd = @serverURL + "/data_request?id=lu_action&serviceId=urn:micasaverde-com:serviceId:HomeAutomationGateway1&action=RunScene&SceneNum=" + grp2[1]
		scenes[scenes.length] = new Array(grp2[1], grp1[1], room, sceneCmd)
		# console.log(grp2[1] + " " + grp1[1] + " " + room + " " + sceneCmd)

	getRooms: (respText) ->
		rooms = {}
		matchRoom = ///
			<room\b(.*?)>
			///
		strMatches = @getMatches(respText, matchRoom)
		for mtch in strMatches
			@addRoom(rooms, mtch)
		rooms

	addRoom: (rooms, tagBody) ->
		re1 = /name="(.*?)"/
		grp1 = re1.exec(tagBody)
		if grp1 is null then return
		re2 = /id="(.*?)"/
		grp2 = re2.exec(tagBody)
		if grp2 is null then return
		rooms[grp2[1]] = grp1[1]

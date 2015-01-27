class IndigoServer
	constructor: (@serverURL) ->
		@ACTIONS_URI = @serverURL + "/actions.json"

	setReadyCallback: (@dataReadyCallback) ->

	getActionGroups: ->
		$.ajax @ACTIONS_URI,
			type: "GET"
			dataType: "json"
			crossDomain: true
			success: (data, textStatus, jqXHR) =>
				@scenes = @getScenes(data)
				@scenes.sort @sortByRoomName
				@dataReadyCallback(@scenes)
				console.log "Indigo data = " + JSON.stringify(@scenes)
				return
		return

	sortByRoomName: (a, b) ->
		if a.groupName < b.groupName then return -1
		if a.groupName > b.groupName then return 1
		return 0

	getScenes: (data, rooms) ->
		indigoScenes = data
		scenes = []
		for indigoScene in indigoScenes
			name = indigoScene.name.split(" - ")
			actionName = indigoScene.name
			if name.length > 1
				roomName = name[0].trim()
				actionName = name[1].trim()
			scene = 
				actionNum: ""
				actionName: roomName + " " + actionName
				groupName: roomName
				actionUrl: @serverURL + "/actions/" + indigoScene.nameURLEncoded + "?_method=execute"
			scenes.push(scene)
		return scenes


	getActionGroupsXML: ->
		matchRe = ///
			<action\b[^>]href="(.*?).xml"[^>]*>(.*?)</action>
			///
		$.ajax @ACTIONS_URI,
			type: "GET"
			dataType: "xml"
			crossDomain: true
			success: (data, textStatus, jqXHR) =>
				bLoop = true
				respText = jqXHR.responseText
				actions = []
				console.log "Got from Indigo " + jqXHR.responseText
				while bLoop
					action = matchRe.exec(respText)
					if action is null then break
					pos = respText.search matchRe
					if pos is -1 then break
					respText = respText.substring(pos+action[0].length)
					actionDict = { actionNum: "", actionName: action[2], groupName: "", actionUrl: @serverURL + action[1] + "?_method=execute" }
					actions[actions.length] = actionDict
					console.log "Adding action " + JSON.stringify(actionDict)
				@dataReadyCallback(actions)


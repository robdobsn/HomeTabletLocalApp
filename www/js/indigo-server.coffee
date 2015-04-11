class IndigoServer
	constructor: (@manager, @serverDef, @dataReadyCallback) ->
		@ACTIONS_URI = @serverDef.url + "/actions.json"
		@numRefreshFailuresSinceSuccess = 0
		@firstRefreshAfterFailSecs = 10
		@nextRefreshesAfterFailSecs = 60
		return

	setReadyCallback: (@dataReadyCallback) ->
		return

	reqActions: ->
		console.log "Requesting Indigo data from " + @ACTIONS_URI
		$.ajax @ACTIONS_URI,
			type: "GET"
			dataType: "json"
			crossDomain: true
			success: (data, textStatus, jqXHR) =>
				@processRecvdActions(data)
				# console.log "Indigo data = " + JSON.stringify(@scenes)
				console.log "Received Indigo data from " + @ACTIONS_URI
				@numRefreshFailuresSinceSuccess = 0
				LocalStorage.set(@ACTIONS_URI, data)
				return
			error: (jqXHR, textStatus, errorThrown) =>
				LocalStorage.logEvent("IndLog", "AjaxFail Status= " + textStatus + " URL= " + @ACTIONS_URI + " Error= " + errorThrown)
				@numRefreshFailuresSinceSuccess++
				setTimeout =>
					@getActionGroups
				, (if @numRefreshFailuresSinceSuccess is 1 then @firstRefreshAfterFailSecs * 1000 else @nextRefreshesAfterFailSecs * 1000)
				# Use stored data if available
				storedData = LocalStorage.get(@ACTIONS_URI)
				# console.log "Getting data stored for " + @ACTIONS_URI + " result = " + storedData
				if storedData?
					# console.log "Using stored data" + JSON.stringify(storedData)
					console.log "Using stored data for " + @ACTIONS_URI
					@processRecvdActions(storedData)
				return
		return

	processRecvdActions: (data) ->
		@scenes = @getScenes(data)
		@scenes.sort @sortByRoomName
		@dataReadyCallback(@serverDef.name, @scenes)

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
				actionUrl: @serverDef.url + "/actions/" + indigoScene.nameURLEncoded + "?_method=execute"
				iconName: @manager.getIconFromActionName(actionName, @serverDef.iconAliasing)
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
					actionDict = { actionNum: "", actionName: action[2], groupName: "", actionUrl: @serverDef.url + action[1] + "?_method=execute" }
					actions[actions.length] = actionDict
					console.log "Adding action " + JSON.stringify(actionDict)
				@dataReadyCallback(@serverDef.name, actions)
		return


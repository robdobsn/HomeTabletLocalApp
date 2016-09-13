class App.DomoticzServer
	constructor: (@manager, @serverDef, @dataReadyCallback) ->
		@ACTIONS_URI = @serverDef.url + "/json.htm?type=scenes"
		@numRefreshFailuresSinceSuccess = 0
		@firstRefreshAfterFailSecs = 10
		@nextRefreshesAfterFailSecs = 60
		return

	setReadyCallback: (@dataReadyCallback) ->
		return

	reqActions: ->
		console.log "Requesting Domoticz data from " + @ACTIONS_URI
		$.ajax @ACTIONS_URI,
			type: "GET"
			dataType: "json"
			crossDomain: true
			success: (data, textStatus, jqXHR) =>
				@processRecvdActions(data)
				# console.log "Domoticz data = " + JSON.stringify(@scenes)
				console.log "Received Domoticz data from " + @ACTIONS_URI
				@numRefreshFailuresSinceSuccess = 0
				App.LocalStorage.set(@ACTIONS_URI, data)
				return
			error: (jqXHR, textStatus, errorThrown) =>
				App.LocalStorage.logEvent("DomLog", "AjaxFail Status= " + textStatus + " URL= " + @ACTIONS_URI + " Error= " + errorThrown)
				@numRefreshFailuresSinceSuccess++
				setTimeout =>
					@getActionGroups
				, (if @numRefreshFailuresSinceSuccess is 1 then @firstRefreshAfterFailSecs * 1000 else @nextRefreshesAfterFailSecs * 1000)
				# Use stored data if available
				storedData = App.LocalStorage.get(@ACTIONS_URI)
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
		serverScenes = data.result
		scenes = []
		if serverScenes?
			for serverScene in serverScenes
				name = serverScene.Name.split(" - ")
				actionName = serverScene.Name
				if name.length > 1
					roomName = name[0].trim()
					actionName = name[1].trim()
				scene = 
					actionNum: ""
					actionName: roomName + " " + actionName
					groupName: roomName
					actionUrl: @serverDef.url + "/json.htm?type=command&param=switchscene&idx=" + serverScene.idx + "&switchcmd=On"
					iconName: @manager.getIconFromActionName(actionName, @serverDef.iconAliasing)
				scenes.push(scene)
		return scenes

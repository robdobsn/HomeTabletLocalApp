class AutomationServer
	constructor: (@intermediateServerURL, @veraServerUrl, @indigoServerUrl, @blindsActions, @doorActions) ->
		@ACTIONS_URI = @intermediateServerURL + "/actions"
		@EXEC_URI = @intermediateServerURL + "/exec"
		@indigoServer = new IndigoServer(@indigoServerUrl)
		@indigoServer.setReadyCallback(@indigoServerReadyCb)
		@veraServer = new VeraServer(@veraServerUrl)
		@veraServer.setReadyCallback(@veraServerReadyCb)
		@useDirectAccessForExec = true # /android_asset/.test(window.location.pathname)
		@veraActions = []
		@indigoActions = []
		@baseAutomationActions = {}
		# Init default door and blinds actions - in case rdhomeserver not running
		@doorActions = 
	        [
	            { actionNum: 0, actionName: "Main Unlock", groupName: "Front Door", actionUrl: @frontDoorUrl + "main-unlock", iconName: "door-unlock" },
	            { actionNum: 0, actionName: "Main Lock", groupName: "Front Door", actionUrl: @frontDoorUrl + "main-lock", iconName: "door-lock" },
	            { actionNum: 0, actionName: "Inner Unlock", groupName: "Front Door", actionUrl: @frontDoorUrl + "inner-unlock", iconName: "door-unlock" },
	            { actionNum: 0, actionName: "Inner Lock", groupName: "Front Door", actionUrl: @frontDoorUrl + "inner-lock", iconName: "door-lock" }
	        ]
        @blindsActions = GetBlindsActions()

	setReadyCallback: (@readyCallback) ->

	indigoServerReadyCb: (actions) =>
		@indigoActions = actions
		@callBackWithSumActions()

	veraServerReadyCb: (actions) =>
		@veraActions = actions
		@callBackWithSumActions()

	callBackWithSumActions: =>
		sumActions = { "doors" : @doorActions, "blinds" : @blindsActions, "vera" : @veraActions, "indigo" : @indigoActions }
		for k,v of @baseAutomationActions
			if k isnt "vera" and k isnt "indigo" and k isnt "blinds" and k isnt "doors"
				sumActions[k] = v
		@readyCallback(sumActions)

	getActionGroups: ->
		@indigoServer.getActionGroups()
		@veraServer.getActionGroups()
		@getActionGroupsFromIntermediateServer()

	getActionGroupsFromIntermediateServer: ->
		# Get the action-groups/scenes
		$.ajax @ACTIONS_URI,
			type: "GET"
			dataType: "json"
			success: (data, textStatus, jqXHR) =>
				if "vera" of data then @veraActions = data.vera
				if "indigo" of data then @indigoActions = data.indigo
				if "doorController" of data then @doorActions = data.doorController
				if "blinds" of data then @blindsActions = data.blinds
				@callBackWithSumActions
			error: (jqXHR, textStatus, errorThrown) =>
				console.log ("Get Actions failed: " + textStatus + " " + errorThrown)

	executeCommand: (cmdParams) =>
		if cmdParams[0..3] is "http"
			$.ajax cmdParams,
				type: "GET"
				dataType: "text"
				success: (data, textStatus, jqXHR) =>

				error: (jqXHR, textStatus, errorThrown) =>
					console.log ("Direct exec command failed: " + textStatus + " " + errorThrown)
		else
			# Execute command on the intermediate server
			$.ajax @EXEC_URI + "/" + cmdParams,
				type: "GET"
				dataType: "text"
				success: (data, textStatus, jqXHR) =>

				error: (jqXHR, textStatus, errorThrown) =>
					console.log ("Intermediate exec command failed: " + textStatus + " " + errorThrown)


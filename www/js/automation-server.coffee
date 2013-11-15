class AutomationServer
	constructor: (@intermediateServerURL, @veraServerUrl, @indigoServerUrl) ->
		@ACTIONS_URI = @intermediateServerURL + "/actions"
		@EXEC_URI = @intermediateServerURL + "/exec"
		@indigoServer = new IndigoServer(@indigoServerUrl)
		@indigoServer.setReadyCallback(@indigoServerReadyCb)
		@veraServer = new VeraServer(@veraServerUrl)
		@veraServer.setReadyCallback(@veraServerReadyCb)
		@useDirectAccessForGet = true # /android_asset/.test(window.location.pathname)
		@useDirectAccessForExec = true # /android_asset/.test(window.location.pathname)
		@veraActions = []
		@indigoActions = []

	setReadyCallback: (@readyCallback) ->

	indigoServerReadyCb: (actions) =>
		@indigoActions = actions
		@callBackWithSumActions()

	veraServerReadyCb: (actions) =>
		@veraActions = actions
		@callBackWithSumActions()

	callBackWithSumActions: =>
		sumActions = { "vera" : @veraActions, "indigo" : @indigoActions }
		@readyCallback(sumActions)

	getActionGroups: ->
		if @useDirectAccessForGet
			@indigoServer.getActionGroups()
			@veraServer.getActionGroups()
		else
			@getActionGroupsFromIntermediateServer()

	getActionGroupsFromIntermediateServer: ->
		# Get the action-groups/scenes
		$.ajax @ACTIONS_URI,
			type: "GET"
			dataType: "json"
			success: (data, textStatus, jqXHR) =>
				@readyCallback(data)
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


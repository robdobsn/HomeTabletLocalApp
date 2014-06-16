class AutomationServer
	constructor: (@automationActionsUrl, @automationExecUrl, @veraServerUrl, @indigoServerUrl, @fibaroServerUrl, @sonosActionsUrl, @mediaPlayHelper, @navigationCallback) ->
		@indigoServer = new IndigoServer(@indigoServerUrl)
		@indigoServer.setReadyCallback(@indigoServerReadyCb)
		@veraServer = new VeraServer(@veraServerUrl)
		@veraServer.setReadyCallback(@veraServerReadyCb)
		@fibaroServer = new FibaroServer(@fibaroServerUrl)
		@fibaroServer.setReadyCallback(@fibaroServerReadyCb)
		@useDirectAccessForExec = true # /android_asset/.test(window.location.pathname)
		@veraActions = []
		@indigoActions = []
		@fibaroActions = []
		@baseAutomationActions = {}
		# Init default door and blinds actions - in case rdhomeserver not running
		@frontDoorUrl = "http://192.168.0.221/"
		@doorActions = 
	        [
	            { tierName:"doorBlindsTier", actionNum: 0, actionName: "Main Unlock", groupName: "Front Door", actionUrl: @frontDoorUrl + "main-unlock", iconName: "door-unlock" },
	            { tierName:"doorBlindsTier", actionNum: 0, actionName: "Main Lock", groupName: "Front Door", actionUrl: @frontDoorUrl + "main-lock", iconName: "door-lock" },
	            { tierName:"doorBlindsTier", actionNum: 0, actionName: "Inner Unlock", groupName: "Front Door", actionUrl: @frontDoorUrl + "inner-unlock", iconName: "door-unlock" },
	            { tierName:"doorBlindsTier", actionNum: 0, actionName: "Inner Lock", groupName: "Front Door", actionUrl: @frontDoorUrl + "inner-lock", iconName: "door-lock" }
	        ]
        @blindsActions = GetBlindsActions()
        @sonosActions = {}
        @soundPlayActions = {}

	setReadyCallback: (@readyCallback) ->

	indigoServerReadyCb: (actions) =>
		@indigoActions = actions
		@callBackWithSumActions()

	veraServerReadyCb: (actions) =>
		@veraActions = actions
		@callBackWithSumActions()

	fibaroServerReadyCb: (actions) =>
		@fibaroActions = actions
		@callBackWithSumActions()

	callBackWithSumActions: =>
		sumActions = { "doors" : @doorActions, "blinds" : @blindsActions, "vera" : @veraActions, "indigo" : @indigoActions, "fibaro" : @fibaroActions }
		for k,v of @baseAutomationActions
			if k isnt "vera" and k isnt "indigo" and k isnt "fibaro" and k isnt "blinds" and k isnt "doors"
				sumActions[k] = v
		sumActions["sonos"] = @sonosActions
		sumActions["soundPlayActions"] = @soundPlayActions
		@readyCallback(sumActions)

	getActionGroups: ->
		@indigoServer.getActionGroups()
		@veraServer.getActionGroups()
#		@fibaroServer.getActionGroups()
		@getActionGroupsFromIntermediateServer()
		@getSonosActions()

	getActionGroupsFromIntermediateServer: ->
		# Get the action-groups/scenes
		$.ajax @automationActionsUrl,
			type: "GET"
			dataType: "json"
			success: (data, textStatus, jqXHR) =>
				if "vera" of data then @veraActions = data.vera
				if "indigo" of data then @indigoActions = data.indigo
				if "fibaro" of data then @fibaroActions = data.fibaro
				if "doorController" of data then @doorActions = data.doorController
				if "blinds" of data then @blindsActions = data.blinds
				@callBackWithSumActions()
			error: (jqXHR, textStatus, errorThrown) =>
				console.log ("Get Actions failed: " + textStatus + " " + errorThrown + " URL=" + @automationActionsUrl)

	getSonosActions: ->
		# Get the sonos actions
		$.ajax @sonosActionsUrl,
			type: "GET"
			dataType: "json"
			success: (data, textStatus, jqXHR) =>
				@sonosActions = data.sonos
				@soundPlayActions = data.soundsToPlay
				@callBackWithSumActions
			error: (jqXHR, textStatus, errorThrown) =>
				console.log ("Get Sonos actions failed: " + textStatus + " " + errorThrown + " URL=" + @sonosActionsUrl)

	executeCommand: (cmdParams) =>
		if not cmdParams? or cmdParams is "" then return
		if cmdParams[0..3] is "http"
			$.ajax cmdParams,
				type: "GET"
				dataType: "text"
				success: (data, textStatus, jqXHR) =>
					@mediaPlayHelper.play("ok")
				error: (jqXHR, textStatus, errorThrown) =>
					console.log ("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdParams)
					@mediaPlayHelper.play("fail")
		else if cmdParams[0..2] is "~~~"
			@navigationCallback(cmdParams[3..])
		else
			# Execute command on the intermediate server
			cmdToExec = @automationExecUrl + "/" + cmdParams
			$.ajax cmdToExec,
				type: "GET"
				dataType: "text"
				success: (data, textStatus, jqXHR) =>
					@mediaPlayHelper.play("ok")
				error: (jqXHR, textStatus, errorThrown) =>
					console.log ("Intermediate exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdToExec)
					@mediaPlayHelper.play("fail")

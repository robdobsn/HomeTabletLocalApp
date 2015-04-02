class AutomationServer
	constructor: (@automationActionsUrl, @automationExecUrl, @veraServerUrl, @indigoServerUrl, @indigo2ServerUrl, @fibaroServerUrl, @sonosActionsUrl, @mediaPlayHelper) ->
		@indigoServer = new IndigoServer(@indigoServerUrl)
		@indigoServer.setReadyCallback(@indigoServerReadyCb)
		@indigo2Server = new IndigoServer(@indigo2ServerUrl)
		@indigo2Server.setReadyCallback(@indigo2ServerReadyCb)
		@veraServer = new VeraServer(@veraServerUrl)
		@veraServer.setReadyCallback(@veraServerReadyCb)
		@fibaroServer = new FibaroServer(@fibaroServerUrl)
		@fibaroServer.setReadyCallback(@fibaroServerReadyCb)
		@useDirectAccessForExec = true # /android_asset/.test(window.location.pathname)
		@veraActions = []
		@indigoActions = []
		@indigo2Actions = []
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
		@sumActionsCallbackTimerId = null

	setReadyCallback: (@readyCallback) ->

	indigoServerReadyCb: (actions) =>
		@indigoActions = actions
		@setSumActionsCallbackTimer()		

	indigo2ServerReadyCb: (actions) =>
		@indigo2Actions = actions
		@setSumActionsCallbackTimer()

	veraServerReadyCb: (actions) =>
		@veraActions = actions
		@setSumActionsCallbackTimer()

	fibaroServerReadyCb: (actions) =>
		@fibaroActions = actions
		@setSumActionsCallbackTimer()

	setSumActionsCallbackTimer: =>
		if @sumActionsCallbackTimerId isnt null then return
		@sumActionsCallbackTimerId = setInterval =>
			@callBackWithSumActions()
		, (2000)
		return

	callBackWithSumActions: =>
		@sumActionsCallbackTimerId = null
		sumActions = { "doors" : @doorActions, "blinds" : @blindsActions, "vera" : @veraActions, "indigo" : @indigoActions, "indigo2" : @indigo2Actions, "fibaro" : @fibaroActions }
		for k,v of @baseAutomationActions
			if k isnt "vera" and k isnt "indigo" and k isnt "indigo2" and k isnt "fibaro" and k isnt "blinds" and k isnt "doors"
				sumActions[k] = v
		sumActions["sonos"] = @sonosActions
		sumActions["soundPlayActions"] = @soundPlayActions
		@readyCallback(sumActions)

	getActionGroups: ->
		@indigoServer.getActionGroups()
		@indigo2Server.getActionGroups()
		# @veraServer.getActionGroups()
		# @fibaroServer.getActionGroups()
		# @getActionGroupsFromIntermediateServer()
		@getSonosActions()
		@setSumActionsCallbackTimer()

	getActionGroupsFromIntermediateServer: ->
		# Get the action-groups/scenes
		$.ajax @automationActionsUrl,
			type: "GET"
			dataType: "json"
			success: (data, textStatus, jqXHR) =>
				if "vera" of data then @veraActions = data.vera
				if "indigo" of data then @indigoActions = data.indigo
				if "indigo2" of data then @indigo2Actions = data.indigo2
				if "fibaro" of data then @fibaroActions = data.fibaro
				if "doorController" of data then @doorActions = data.doorController
				if "blinds" of data then @blindsActions = data.blinds
				@callBackWithSumActions()
			error: (jqXHR, textStatus, errorThrown) =>
				console.error ("Get Actions failed: " + textStatus + " " + errorThrown + " URL=" + @automationActionsUrl)

	getSonosActions: ->
		# Get the sonos actions
		if @sonosActionsUrl is "" then return
		$.ajax @sonosActionsUrl,
			type: "GET"
			dataType: "json"
			success: (data, textStatus, jqXHR) =>
				@sonosActions = data.sonos
				@soundPlayActions = data.soundsToPlay
				@callBackWithSumActions
			error: (jqXHR, textStatus, errorThrown) =>
				console.error ("Get Sonos actions failed: " + textStatus + " " + errorThrown + " URL=" + @sonosActionsUrl)

	executeCommand: (cmdParams) =>
		if not cmdParams? or cmdParams is "" then return
		if cmdParams[0..3] is "http"
			$.ajax cmdParams,
				type: "GET"
				dataType: "text"
				success: (data, textStatus, jqXHR) =>
					@mediaPlayHelper.play("ok")
				error: (jqXHR, textStatus, errorThrown) =>
					console.error ("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdParams)
					@mediaPlayHelper.play("fail")
		else
			# Execute command on the intermediate server
			cmdToExec = @automationExecUrl + "/" + cmdParams
			$.ajax cmdToExec,
				type: "GET"
				dataType: "text"
				success: (data, textStatus, jqXHR) =>
					@mediaPlayHelper.play("ok")
				error: (jqXHR, textStatus, errorThrown) =>
					console.error ("Intermediate exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdToExec)
					@mediaPlayHelper.play("fail")

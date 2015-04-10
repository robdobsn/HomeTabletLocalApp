class AutomationManager
	constructor: (@app, @readyCallback) ->
		@serverDefs = []
		@servers = []
		@sumActions = {}
		@iconAliasing = {}

	setReadyCallback: (@readyCallback) ->

	requestUpdate: (configData) ->
		# Stash icon aliasing info
		@iconAliasing = if "iconAliasing" of configData.common then configData.common.iconAliasing else {}
		# Get actions from config data
		if "fixedActions" of configData.common
			@sumActions["fixedActions"] = configData.common.fixedActions
		else
			@sumActions["fixedActions"] = null
		# Check if server list has changed
		if "servers" not of configData.common then return
		dataChanged = false
		if @servers.length is configData.common.servers.length	
			for serverDef, idx in configData.common.servers
				if @serverDefs[idx].type isnt serverDef.type then dataChanged = true
				if @serverDefs[idx].name isnt serverDef.name then dataChanged = true
				if @serverDefs[idx].url isnt serverDef.url then dataChanged = true
		else
			dataChanged = true
		# If changed then create servers
		if dataChanged
			@servers = []
			for serverDef in configData.common.servers
				if serverDef.type is "indigo"
					@servers.push new IndigoServer(this, serverDef, @actionsReadyCb)
				else if serverDef.type is "indigo-test"
					@servers.push new IndigoTestServer(this, serverDef, @actionsReadyCb)
				else if serverDef.type is "vera"
					@servers.push new VeraServer(this, serverDef, @actionsReadyCb)
				else if serverDef.type is "fibaro"
					@servers.push new FibaroServer(this, serverDef, @actionsReadyCb)
		# Request data from servers
		for server in @servers
			server.reqActions()
		# Callback now with initial actions
		@readyCallback(true)
		return

	actionsReadyCb: (serverName, actions) =>
		@sumActions[serverName] = actions
		@readyCallback(true)
		return

	getActionGroups: ->
		return @sumActions

	executeCommand: (cmdParams) =>
		if not cmdParams? or cmdParams is "" then return
		$.ajax cmdParams,
			type: "GET"
			dataType: "text"
			success: (data, textStatus, jqXHR) =>
				@app.mediaPlayHelper.play("ok")
				return
			error: (jqXHR, textStatus, errorThrown) =>
				console.error ("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdParams)
				@app.mediaPlayHelper.play("fail")
				return

	getIconFromActionName: (actionName, aliasingGroup) ->
		if not aliasingGroup? then return ""
		if aliasingGroup not of @iconAliasing then return ""
		aliases = @iconAliasing[aliasingGroup]
		for aliasDef in aliases
			if actionName.match(aliasDef.regex)
				return aliasDef.iconName
		return ""


		# if cmdParams[0..3] is "http"
		# 	$.ajax cmdParams,
		# 		type: "GET"
		# 		dataType: "text"
		# 		success: (data, textStatus, jqXHR) =>
		# 			@app.mediaPlayHelper.play("ok")
		# 			return
		# 		error: (jqXHR, textStatus, errorThrown) =>
		# 			console.error ("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdParams)
		# 			@app.mediaPlayHelper.play("fail")
		# 			return
		# else
		# 	# Execute command on the intermediate server
		# 	cmdToExec = @automationExecUrl + "/" + cmdParams
		# 	$.ajax cmdToExec,
		# 		type: "GET"
		# 		dataType: "text"
		# 		success: (data, textStatus, jqXHR) =>
		# 			@app.mediaPlayHelper.play("ok")
		# 			return
		# 		error: (jqXHR, textStatus, errorThrown) =>
		# 			console.error ("Intermediate exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdToExec)
		# 			@app.mediaPlayHelper.play("fail")
		# 			return
		# return

		# @automationActionsUrl, @automationExecUrl, @veraServerUrl, @indigoServerUrl, @indigo2ServerUrl, @fibaroServerUrl, @sonosActionsUrl, @mediaPlayHelper
        # @indigoServerUrl = "http://IndigoServer.local:8176"
        # @indigo2ServerUrl = "http://IndigoDown.local:8176"
        # @fibaroServerUrl = "http://macallan:5079"
        # @veraServerUrl = "http://192.168.0.206:3480"


		  #   automationServerReadyCb: (actions, serverType) =>
    #     # Callback when data received from the automation server (scenes/actions)
    #     if @checkActionGroupsChanged(@automationActionGroups, actions)
    #         @automationActionGroups = actions
    #         @buildAndDisplayUI()
    #     return

    # checkActionGroupsChanged: (oldActionMap, newActionMap) ->
    #     # Deep object comparison to see if configuration has changed
    #     if Object.keys(oldActionMap).length isnt Object.keys(newActionMap).length then return true
    #     for servType, oldActions of oldActionMap
    #         if not (servType of newActionMap) then return true
    #         newActions = newActionMap[servType]
    #         if @checkActionsForServer(oldActions, newActions) then return true
    #     return false

    # checkActionsForServer: (oldActions, newActions) ->
    #     if oldActions.length isnt newActions.length then return true
    #     for oldAction, j in oldActions
    #         newAction = newActions[j]
    #         if Object.keys(oldAction).length isnt Object.keys(newAction).length then return true
    #         for k, v of oldAction
    #             if not k of newAction then return true
    #             if v isnt newAction[k] then return true
    #     return false
    #     
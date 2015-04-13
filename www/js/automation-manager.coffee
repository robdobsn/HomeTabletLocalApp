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
		if "servers" of configData.common
			dataChanged = false
			if @serverDefs.length is configData.common.servers.length
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
					if serverDef.type is "indigo" or serverDef.type is "Indigo"
						@servers.push new IndigoServer(this, serverDef, @actionsReadyCb)
					else if serverDef.type is "indigo-test"
						@servers.push new IndigoTestServer(this, serverDef, @actionsReadyCb)
					else if serverDef.type is "vera" or serverDef.type is "Vera"
						@servers.push new VeraServer(this, serverDef, @actionsReadyCb)
					else if serverDef.type is "fibaro" or serverDef.type is "Fibaro"
						@servers.push new FibaroServer(this, serverDef, @actionsReadyCb)
		else
			@servers = []
		@serverDefs = configData.common.servers
		# Request data from servers
		for server in @servers
			server.reqActions()
		# Callback now with initial actions
		@readyCallback(true)
		return

	actionsReadyCb: (serverName, actions) =>
		dataChanged = true
		if serverName of @sumActions
			dataChanged = JSON.stringify(@sumActions[serverName]) isnt actions
		if dataChanged
			@sumActions[serverName] = actions
		@readyCallback(dataChanged)
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

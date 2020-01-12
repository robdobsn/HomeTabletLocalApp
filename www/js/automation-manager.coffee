class App.AutomationManager
	constructor: (@app, @readyCallback) ->
		@serverDefs = []
		@servers = []
		@sumActions = {}
		@iconAliasing = {}
		@combinedActions = {}

	setReadyCallback: (@readyCallback) ->
		return

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
						@servers.push new App.IndigoServer(this, serverDef, @actionsReadyCb)
					else if serverDef.type is "indigo-test"
						@servers.push new App.IndigoTestServer(this, serverDef, @actionsReadyCb)
					else if serverDef.type is "vera" or serverDef.type is "Vera"
						@servers.push new App.VeraServer(this, serverDef, @actionsReadyCb)
					else if serverDef.type is "fibaro" or serverDef.type is "Fibaro"
						@servers.push new App.FibaroServer(this, serverDef, @actionsReadyCb)
					else if serverDef.type is "domoticz" or serverDef.type is "Domoticz"
						@servers.push new App.DomoticzServer(this, serverDef, @actionsReadyCb)
					else if serverDef.type is "robhome" or serverDef.type is "RobHome"
						@servers.push new App.RobHomeServer(this, serverDef, @actionsReadyCb)
		else
			@servers = []
		@serverDefs = configData.common.servers
		# Request data from servers
		for server in @servers
			server.reqActions()
		# Callback now with initial actions (fixed actions)
		@readyCallback(true)
		return

	actionsReadyCb: (serverName, actions) =>
		# Check if the data for this action has changed
		dataChanged = true
		if serverName of @sumActions
			dataChanged = JSON.stringify(@sumActions[serverName]) isnt actions
		if dataChanged
			@sumActions[serverName] = actions
		# Process the data further to remove duplications (two servers might have the same action)
		# and convert these duplicates into separate action maintained by this object
		@combinedActions["actions"] = @generateCombinedActions() 
		@readyCallback(dataChanged)
		return

	getActionGroups: ->
		return @combinedActions

	generateCombinedActions: () ->
		# Flatten all sources into an actions list
		mergedActionsList = []
		duplicatedActions = {}
		# Go through the actions of each server
		for serverName, serverActions of @sumActions
			for serverAction in serverActions
				dupFound = false
				# Check against other server's actions
				for otherServerName, otherServerActions of @sumActions
					if otherServerName is serverName
						continue
					for otherServerAction in otherServerActions
						if otherServerAction.actionName is serverAction.actionName and
							((not otherServerAction.groupName? and not serverAction.groupName?) or (otherServerAction.groupName is serverAction.groupName))
								if serverAction.actionName of duplicatedActions
									duplicatedActions[serverAction.actionName].actionUrl += ";" + serverAction.actionUrl
								else
									duplicatedActions[serverAction.actionName] = serverAction
								dupFound = true
								break
					if dupFound
						break
				if not dupFound
					mergedActionsList.push serverAction
		for key,val of duplicatedActions
			mergedActionsList.push val
			console.error("MergedAction " + val.actionUrl)
		return mergedActionsList

	soundResult: (cmdsToDo, cmdsCompleted, cmdsFailed) ->
		if cmdsCompleted is cmdsToDo
			if cmdsFailed is 0
				@app.mediaPlayHelper.play("ok")
			else
				@app.mediaPlayHelper.play("fail")
		return

	executeCommand: (cmdParams) =>
		if not cmdParams? or cmdParams is "" then return
		# Commands can be ; separated
		cmds = cmdParams.split(";")
		@app.mediaPlayHelper.play("click")
		cmdsCompleted = 0
		cmdsFailed = 0
		cmdsToDo = cmds.length
		for cmd in cmds
			# Check if command contains "~POST~" - to indicate POST rather than GET
			if cmd.indexOf("~POST~") > 0
				console.log "WallTabletDebug Exec POST command " + cmd
				cmdParts = cmd.split("~")
				$.ajax cmdParts[0],
					type: "POST"
					dataType: "text"
					data: cmdParts[2]
					success: (data, textStatus, jqXHR) =>
						cmdsCompleted++
						@soundResult(cmdsToDo, cmdsCompleted, cmdsFailed)
						return
					error: (jqXHR, textStatus, errorThrown) =>
						console.error ("WallTabletDebug POST exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmd)
						cmdsFailed++
						cmdsCompleted++
						return
			else
				console.log "WallTabletDebug Exec GET command " + cmd
				$.ajax cmd,
					type: "GET"
					dataType: "text"
					success: (data, textStatus, jqXHR) =>
						cmdsCompleted++
						@soundResult(cmdsToDo, cmdsCompleted, cmdsFailed)
						return
					error: (jqXHR, textStatus, errorThrown) =>
						console.error ("WallTabletDebug GET exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmd)
						cmdsFailed++
						cmdsCompleted++
						return
		return

	getIconFromActionName: (actionName, aliasingGroup) ->
		if not aliasingGroup? then return ""
		if aliasingGroup not of @iconAliasing then return ""
		aliases = @iconAliasing[aliasingGroup]
		for aliasDef in aliases
			if actionName.match(aliasDef.regex)
				return aliasDef.iconName
		return ""

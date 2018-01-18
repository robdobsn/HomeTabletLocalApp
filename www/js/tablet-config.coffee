class App.TabletConfigManager
	constructor: (@defaultTabletName) ->
		@configData = {}
		@defaultTabletConfig = new App.DefaultTabletConfig()
		@defaultConfigSettings =
			showCalServerSetting: true
			showAutomationServerSettings: ["Indigo","Vera","Fibaro"]
			showEnergyServerSetting: true
		return

	getTabName: ->
		# See if the tablet's name is in the local storage
		tabName = App.LocalStorage.get("DeviceConfigName")
		if not tabName? or tabName is ""
			tabName = @defaultTabletName
		return tabName

	getReqUrl: ->
		reqURL = App.LocalStorage.get("ConfigServerUrl")
		if not reqURL? or reqURL is ""
			return ""
		tabName = @getTabName()
		reqURL = reqURL.trim()
		reqURL = reqURL + (if reqURL.slice(-1) is "/" then "" else "/") + "tabletconfig/" + tabName
		return reqURL

	setReadyCallback: (@readyCallback) ->

	getConfigData: ->
		return @configData
		
	addFavouriteButton: (buttonInfo) ->
		console.log "Add " + buttonInfo.tileName
		if "favourites" not of @configData
			@configData.favourites = []
		@configData.favourites.push
			tileName: buttonInfo.tileName
			groupName: buttonInfo.groupName
		@saveDeviceConfig()

	deleteFavouriteButton: (buttonInfo) ->
		console.log "Delete " + buttonInfo.tileName
		if "favourites" not of @configData
			return
		favIdx = -1
		for fav, idx in @configData.favourites
			if fav.tileName is buttonInfo.tileName and fav.groupName is buttonInfo.groupName
				favIdx = idx
				break
		if favIdx >= 0
			@configData.favourites.splice(favIdx, 1)
			@saveDeviceConfig()

	saveDeviceConfig: ->
		reqURL = @getReqUrl()
		App.LocalStorage.set(reqURL, @configData)
		tabName = @getTabName()
		if not tabName? or tabName is ""
			console.log "WallTabletDebug Unable to save device config as tablet name unknown"
		else
			console.log "WallTabletDebug Saving device config for " + tabName
		# Store back to the server 
		$.ajax 
			url: reqURL
			type: 'POST'
			data: JSON.stringify({"favourites":@configData.favourites})
			contentType: "application/json"
			success: (data, status, response) =>
				console.log "WallTabletDebug Sent new config data ok"
			error: (jqXHR, textStatus, errorThrown) =>
				console.error ("WallTabletDebug Failed to send new config data: " + textStatus + " " + errorThrown)

	requestConfig: ->
		reqURL = @getReqUrl()

		# Handle no config server situation
		if reqURL is ""
			@configData = @defaultTabletConfig.get(@defaultConfigSettings)
			@readyCallback()
			return

		# Get the configuration from the server
		tabName = @getTabName()
		console.log("WallTabletDebug Requesting tablet config from tabname " + @getTabName() + " using URL " + reqURL)

		# get the tablet config from a server
		@catchAjaxFail = setTimeout =>
			@ajaxFailTimeout()
		, 2000
		$.ajax reqURL,
			type: "GET"
			dataType: "text"
			crossDomain: true
			timeout: 1500
			success: (data, textStatus, jqXHR) =>
				clearTimeout(@catchAjaxFail)
				jsonText = jqXHR.responseText
				jsonData = $.parseJSON(jsonText)
				if jsonText is "{}"
					console.log("WallTabletDebug Got tablet config but it's empty")
					@configData = @defaultTabletConfig.get(@defaultConfigSettings)
				else
					console.log "WallTabletDebug Got tablet config data"
					tabName = jsonData["deviceName"]
					curTabName = App.LocalStorage.get("DeviceConfigName")
					if tabName? and tabName isnt curTabName
						App.LocalStorage.set("DeviceConfigName", tabName)
						console.log("WallTabletDebug DeviceConfigName was " + curTabName + " now set to " + tabName)

						console.log("WallTabletDebug " + " TABLETCONFIG DeviceConfigName was " + curTabName + " now set to " + tabName);

						App.LocalStorage.logEvent("CnfLog", "DeviceConfigName was " + curTabName + " now set to " + tabName)
					@configData = jsonData
					App.LocalStorage.set(reqURL, @configData)
				@readyCallback()
				console.log "WallTabletDebug Storing data for " + reqURL + " = " + JSON.stringify(jsonData)
				return
			error: (jqXHR, textStatus, errorThrown) =>
				console.log "WallTabletDebug Get tablet config data failed with an error " + textStatus
				# Use stored data if available
				clearTimeout(@catchAjaxFail)
				storedData = App.LocalStorage.get(reqURL)
				console.log "WallTabletDebug Config Getting data stored for " + reqURL + " result = " + storedData
				if storedData?
					# console.log "Using stored data" + JSON.stringify(storedData)
					console.log "WallTabletDebug Using stored data for " + reqURL
					@configData = storedData
				else
					@configData = @defaultTabletConfig.get(@defaultConfigSettings)
				@readyCallback()
				return
		return

	ajaxFailTimeout: ->
		console.log("WallTabletDebug Get tablet config timed out via setTimeout")
		@configData = @defaultTabletConfig.get(@defaultConfigSettings)
		@readyCallback()
		return

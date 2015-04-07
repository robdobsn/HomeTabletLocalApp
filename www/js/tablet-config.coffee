class TabletConfig
	constructor: (@configURL, @defaultTabletName) ->
		@configData = {}
		return

	getTabName: ->
		# See if the tablet's name is in the local storage
		tabName = LocalStorage.get("DeviceConfigName")
		if not tabName?
			tabName = @defaultTabletName
		return tabName

	getReqUrl: ->
		reqURL = @configURL
		tabName = @getTabName()
		if tabName?
			reqURL = reqURL + "/" + tabName
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
		LocalStorage.set(reqURL, @configData)
		tabName = @getTabName()
		if not tabName? or tabName is ""
			console.log "Unable to save device config as tablet name unknown"
		else
			console.log "Saving device config for " + tabName
		console.log "NEED TO IMPLEMENT SAVING BACK TO SERVER " + reqURL
		$.ajax 
			url: reqURL
			type: 'POST'
			data: JSON.stringify({"favourites":@configData.favourites})
			contentType: "application/json"
			success: (data, status, response) =>
				console.log "Sent new config data ok"
			error: (jqXHR, textStatus, errorThrown) =>
				console.error ("Failed to send new config data: " + textStatus + " " + errorThrown)

	requestConfig: ->
		reqURL = @getReqUrl()
		tabName = @getTabName()
		console.log("Requesting tablet config with URL " + reqURL)

		# get the tablet config from a server
		$.ajax reqURL,
			type: "GET"
			dataType: "text"
			crossDomain: true
			success: (data, textStatus, jqXHR) =>
				jsonText = jqXHR.responseText
				jsonData = $.parseJSON(jsonText)
				tabName = jsonData["deviceName"]
				curTabName = LocalStorage.get("DeviceConfigName")
				if tabName? and tabName isnt curTabName
					LocalStorage.set("DeviceConfigName", tabName)
					console.log("DeviceConfigName was " + curTabName + " now set to " + tabName)
					LocalStorage.logEvent("CnfLog", "DeviceConfigName was " + curTabName + " now set to " + tabName)
				@configData = jsonData
				LocalStorage.set(reqURL, @configData)
				@readyCallback()
				# console.log "Storing data for " + reqURL + " = " + JSON.stringify(jsonData)
				return
			error: (jqXHR, textStatus, errorThrown) =>
				# Use stored data if available
				reqURL = "http://macallan:5076/tabletconfig/tablanding"
				storedData = LocalStorage.get(reqURL)
				console.log "Config Getting data stored for " + reqURL + " result = " + storedData
				if storedData?
					# console.log "Using stored data" + JSON.stringify(storedData)
					console.log "Using stored data for " + reqURL
					@configData = storedData
				return
		return

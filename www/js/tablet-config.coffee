class App.TabletConfigManager
	constructor: (@defaultTabletName, @defaultTabletConfigUrl) ->
		@configData = {}
		@defaultTabletConfig = new App.DefaultTabletConfig()
		@defaultConfigSettings =
			showCalServerSetting: true
			showAutomationServerSettings: ["Indigo","Vera","Fibaro"]
			showEnergyServerSetting: true
		console.log("tablet-config constructed with defaults defaultTabletName " + @defaultTabletName)
		return

	getTabName: ->
		# See if the tablet's name is in the local storage
		tabNameStored = App.LocalStorage.get("DeviceConfigName")
		tabName = @defaultTabletName
		if tabNameStored? and tabNameStored isnt ""
			tabName = tabNameStored
			console.log("tablet-config getTabName from local storage = " + tabName)
		else
			console.log("tablet-config getTabName using default " + tabName)
		return tabName

	getReqUrl: ->
		reqURL = @defaultTabletConfigUrl
		if not reqURL? or reqURL is ""
			return ""
		tabName = @getTabName()
		reqURL = reqURL.trim()
		reqURL = reqURL + (if reqURL.slice(-1) is "/" then "" else "/") + "tabletconfig/" + tabName
		console.log("tablet-config getReqUrl " + reqURL)
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
			console.log "tablet-config Unable to save device config as tablet name unknown"
		else
			console.log "tablet-config Saving device config for " + tabName
		# Store back to the server 
		$.ajax 
			url: reqURL
			type: 'POST'
			data: JSON.stringify({"favourites":@configData.favourites})
			contentType: "application/json"
			success: (data, status, response) =>
				console.log "tablet-config Sent new config data ok"
			error: (jqXHR, textStatus, errorThrown) =>
				console.error ("tablet-config Failed to send new config data: " + textStatus + " " + errorThrown)

	applyStoredData: (reqURL) ->
		storedData = App.LocalStorage.get(reqURL)
		console.log "tablet-config Config Getting data stored for " + reqURL + " result = " + storedData
		if storedData?
			# console.log "Using stored data" + JSON.stringify(storedData)
			console.log "tablet-config Using stored data for " + reqURL
			@configData = storedData
		else
			@configData = @defaultTabletConfig.get(@defaultConfigSettings)
		@readyCallback()

	requestConfig: ->
		reqURL = @getReqUrl()

		# Handle no config server situation
		if reqURL is ""
			@configData = @defaultTabletConfig.get(@defaultConfigSettings)
			@readyCallback()
			return

		# Get the configuration from the server
		tabName = @getTabName()
		console.log("tablet-config Requesting tablet config from tabname " + @getTabName() + " using URL " + reqURL)

		# get the tablet config from a server
		@catchAjaxFail = setTimeout(@ajaxFailTimeout, 2000)
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
					console.log("tablet-config Got tablet config but it's empty")
					@configData = @defaultTabletConfig.get(@defaultConfigSettings)
					@applyStoredData(reqURL)
				else
					# console.log "tablet-config Got tablet config data"
					curTabName = @getTabName()
					tabName = if "deviceName" of jsonData then jsonData.deviceName else curTabName
					if tabName? and tabName isnt curTabName
						App.LocalStorage.set("DeviceConfigName", tabName)
						console.log("tablet-config DeviceConfigName was " + curTabName + " now set to " + tabName)
						App.LocalStorage.logEvent("CnfLog", "DeviceConfigName was " + curTabName + " now set to " + tabName)
					@configData = jsonData
					App.LocalStorage.set(reqURL, @configData)
					if ("common" of jsonData) and ("servers" of jsonData.common)
						console.log "tablet-config got " + tabName + " len " + JSON.stringify(jsonData).length + " #servers " + jsonData.common.servers.length
					else
						console.log "tablet-config got " + tabName + " len " + JSON.stringify(jsonData).length + " NO SERVERS DEFINED"
					if ("deviceName" of jsonData)
						console.log "tablet-config got " + tabName + " deviceName " + jsonData.deviceName
					else
						console.log "tablet-config got " + tabName + " deviceName NOT PRESENT"
						console.log ""
						console.log jsonText
						console.log ""
					if ("roomName" of jsonData)
						console.log "tablet-config got " + tabName + " roomName " + jsonData.roomName
					else
						console.log "tablet-config got " + tabName + " roomName NOT PRESENT"
					if ("sonosRoomName" of jsonData)
						console.log "tablet-config got " + tabName + " sonosRoomName " + jsonData.sonosRoomName
					else
						console.log "tablet-config got " + tabName + " sonosRoomName NOT PRESENT"
					@readyCallback()
				return
			error: (jqXHR, textStatus, errorThrown) =>
				console.log "tablet-config Get tablet config data failed with an error " + textStatus
				# Use stored data if available
				clearTimeout(@catchAjaxFail)
				@applyStoredData(reqURL)
				return
		return

	ajaxFailTimeout: ->
		console.log("tablet-config Get tablet config timed out via setTimeout")
		@configData = @defaultTabletConfig.get(@defaultConfigSettings)
		@readyCallback()
		return

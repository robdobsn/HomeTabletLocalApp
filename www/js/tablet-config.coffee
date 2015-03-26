class TabletConfig
	constructor: (@configURL) ->
		@configData = {}
		return

	getConfigData: ->
		return @configData
		
	requestConfig: ->
		reqURL = @configURL
		# See if the tablet's name is in the local storage
		tabName = LocalStorage.get("DeviceConfigName")
		if tabName?
			reqURL = reqURL + "/" + tabName
		console.log("Requesting tablet config with URL " + reqURL)

		# To avoid giving each tablet a name or other ID
		# the tablet's IP address is used to retrieve the config
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
				LocalStorage.set(reqURL, jsonData)
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

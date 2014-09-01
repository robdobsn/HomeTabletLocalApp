class TabletConfig
	constructor: (@configURL) ->

	setReadyCallback: (@readyCallback) ->

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
				if tabName?
					LocalStorage.set("DeviceConfigName", tabName)
					console.log("DeviceConfigName set to " + tabName)
				@readyCallback(jsonData)


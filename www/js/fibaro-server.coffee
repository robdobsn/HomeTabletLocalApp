class FibaroServer
	constructor: (@serverURL) ->
		@ROOMS_URL = @serverURL + "/api/rooms"
		@SCENES_URL = @serverURL + "/api/scenes"

	setReadyCallback: (@dataReadyCallback) ->
		
	getActionGroups: ->
		# xmlhttp = new XMLHttpRequest()
		# xmlhttp.onreadystatechange = () =>
		# 	if xmlhttp.readyState == 4
		# 		if xmlhttp.status == 200
		# 			alert "Resp " + xmlhttp.responseText
		# 		else if xmlhttp.status == 400
		# 			alert 'There was an error 400'
		# 		else
		# 			alert 'Other error ' + xmlhttp.status
		# 	else
		# 		alert('something else other than 200 was returned')
		# xmlhttp.open("GET", @ROOMS_URL, true)
		# xmlhttp.setRequestHeader('Content-type', 'application/json')
		# xmlhttp.setRequestHeader("Authorization", "Basic " + btoa("admin" + ":" + "b6107430"))
		# xmlhttp.send()

		# return
		console.log "Get from Fibaro " + @ROOMS_URL
		$.ajax @ROOMS_URL,
			type: "GET"
			dataType: "json"
			# contentType: 'application/text'
			crossDomain: true
			# headers: "Authorization": "Basic " + btoa("admin" + ":" + "b6107430")
			# beforeSend: (xhr) =>
			#     xhr.setRequestHeader("Authorization", @makeBasicAuth("admin", "b6107430"))
			error: (jqXHR, textStatus, errorThrown) =>
				console.log ("Fibaro Rooms failed: " + textStatus + " " + errorThrown)
				return
			success: (data, textStatus, jqXHR) =>
				console.log "Got from Fibaro"
				@rooms = data
				$.ajax @SCENES_URL,
					type: "GET"
					dataType: "json"
					crossDomain: true
					success: (data, textStatus, jqXHR) =>
						@scenes = @getScenes(data, @rooms)
						@scenes.sort @sortByRoomName
						@dataReadyCallback(@scenes)
						console.log "Fibaro data = " + JSON.stringify(@scenes)
						return
				return

	makeBasicAuth: (username, password) ->
		tok = username + ':' + password
		hash = btoa(tok)
		return 'Basic ' + hash

	sortByRoomName: (a, b) ->
		if a.groupName < b.groupName then return -1
		if a.groupName > b.groupName then return 1
		return 0

	getScenes: (data, rooms) ->
		fibaroScenes = data
		scenes = []
		for fibaroScene in fibaroScenes
			if not "roomID" of fibaroScene
				continue
			for room in rooms
				if not (("id" of room) and ("name" of room))
					continue
				if room.id is fibaroScene.roomID
					sceneCmd = @serverURL + "/api/sceneControl?id=" + fibaroScene.id + "&action=start"
					scene = { actionNum: fibaroScene.id, actionName: fibaroScene.name, groupName: room.name, actionUrl: sceneCmd }
					scenes.push(scene)
					break
		return scenes

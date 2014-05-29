class FibaroServer
	constructor: (@serverURL) ->
		@ROOMS_URL = @serverURL + "/api/rooms"
		@SCENES_URL = @serverURL + "/api/scenes"

	setReadyCallback: (@dataReadyCallback) ->
		
	getActionGroups: ->
		$.ajax @ROOMS_URL,
			type: "GET"
			dataType: "json"
			crossDomain: true
			error: (jqXHR, textStatus, errorThrown) =>
				alert ("Fibaro Rooms failed: " + textStatus + " " + errorThrown)
			success: (data, textStatus, jqXHR) =>
				alert ("Fibaro done ok")
				@rooms = data
				$.ajax @SCENES_URL,
					type: "GET"
					dataType: "json"
					crossDomain: true
					success: (data, textStatus, jqXHR) =>
						@scenes = @getScenes(data, @rooms)
						@scenes.sort @sortByRoomName
						@dataReadyCallback(@scenes)

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

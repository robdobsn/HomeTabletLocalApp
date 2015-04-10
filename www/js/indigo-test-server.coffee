class IndigoTestServer
	constructor: (@manager, @serverDef, @dataReadyCallback) ->

	reqActions: ->
		testActions =
		[
			{
				"name": "Grace - Bright",
				"nameURLEncoded": "Grace%20-%20Bright",
				"restParent": "actions",
				"restURL": "/actions/Grace%20-%20Bright.json"
			}
			, {
				"name": "Grace - Mood",
				"nameURLEncoded": "Grace%20-%20Mood",
				"restParent": "actions",
				"restURL": "/actions/Grace%20-%20Mood.json"
			}
			, {
				"name": "Grace - Off",
				"nameURLEncoded": "Grace%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Grace%20-%20Off.json"
			}
			, {
				"name": "Grace - Stars",
				"nameURLEncoded": "Grace%20-%20Stars",
				"restParent": "actions",
				"restURL": "/actions/Grace%20-%20Stars.json"
			}
			, {
				"name": "Grace Bath - Bright",
				"nameURLEncoded": "Grace%20Bath%20-%20Bright",
				"restParent": "actions",
				"restURL": "/actions/Grace%20Bath%20-%20Bright.json"
			}
			, {
				"name": "Grace Bath - Mood",
				"nameURLEncoded": "Grace%20Bath%20-%20Mood",
				"restParent": "actions",
				"restURL": "/actions/Grace%20Bath%20-%20Mood.json"
			}
			, {
				"name": "Grace Bath - Off",
				"nameURLEncoded": "Grace%20Bath%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Grace%20Bath%20-%20Off.json"
			}
			, {
				"name": "Guest Bath - Off",
				"nameURLEncoded": "Guest%20Bath%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Guest%20Bath%20-%20Off.json"
			}
			, {
				"name": "Guest Bath - On",
				"nameURLEncoded": "Guest%20Bath%20-%20On",
				"restParent": "actions",
				"restURL": "/actions/Guest%20Bath%20-%20On.json"
			}
			, {
				"name": "Guest Bed - Off",
				"nameURLEncoded": "Guest%20Bed%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Guest%20Bed%20-%20Off.json"
			}
			, {
				"name": "Guest Bed - On",
				"nameURLEncoded": "Guest%20Bed%20-%20On",
				"restParent": "actions",
				"restURL": "/actions/Guest%20Bed%20-%20On.json"
			}
			, {
				"name": "Hall - Mood",
				"nameURLEncoded": "Hall%20-%20Mood",
				"restParent": "actions",
				"restURL": "/actions/Hall%20-%20Mood.json"
			}
			, {
				"name": "Hall - Off",
				"nameURLEncoded": "Hall%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Hall%20-%20Off.json"
			}
			, {
				"name": "Kitchen - Bright",
				"nameURLEncoded": "Kitchen%20-%20Bright",
				"restParent": "actions",
				"restURL": "/actions/Kitchen%20-%20Bright.json"
			}
			, {
				"name": "Kitchen - Mood",
				"nameURLEncoded": "Kitchen%20-%20Mood",
				"restParent": "actions",
				"restURL": "/actions/Kitchen%20-%20Mood.json"
			}
			, {
				"name": "Kitchen - Off",
				"nameURLEncoded": "Kitchen%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Kitchen%20-%20Off.json"
			}
			, {
				"name": "Lounge - Bright",
				"nameURLEncoded": "Lounge%20-%20Bright",
				"restParent": "actions",
				"restURL": "/actions/Lounge%20-%20Bright.json"
			}
			, {
				"name": "Lounge - Off",
				"nameURLEncoded": "Lounge%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Lounge%20-%20Off.json"
			}
			, {
				"name": "Master Bath - Mood",
				"nameURLEncoded": "Master%20Bath%20-%20Mood",
				"restParent": "actions",
				"restURL": "/actions/Master%20Bath%20-%20Mood.json"
			}
			, {
				"name": "Master Bath - Off",
				"nameURLEncoded": "Master%20Bath%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Master%20Bath%20-%20Off.json"
			}
			, {
				"name": "Master Bath - On",
				"nameURLEncoded": "Master%20Bath%20-%20On",
				"restParent": "actions",
				"restURL": "/actions/Master%20Bath%20-%20On.json"
			}
			, {
				"name": "Master Bed - Mood",
				"nameURLEncoded": "Master%20Bed%20-%20Mood",
				"restParent": "actions",
				"restURL": "/actions/Master%20Bed%20-%20Mood.json"
			}
			, {
				"name": "Master Bed - Mood 2",
				"nameURLEncoded": "Master%20Bed%20-%20Mood%202",
				"restParent": "actions",
				"restURL": "/actions/Master%20Bed%20-%20Mood%202.json"
			}
			, {
				"name": "Master Bed - Off",
				"nameURLEncoded": "Master%20Bed%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Master%20Bed%20-%20Off.json"
			}
			, {
				"name": "Master Bed - On",
				"nameURLEncoded": "Master%20Bed%20-%20On",
				"restParent": "actions",
				"restURL": "/actions/Master%20Bed%20-%20On.json"
			}
			, {
				"name": "Office - Bright",
				"nameURLEncoded": "Office%20-%20Bright",
				"restParent": "actions",
				"restURL": "/actions/Office%20-%20Bright.json"
			}
			, {
				"name": "Office - Mood",
				"nameURLEncoded": "Office%20-%20Mood",
				"restParent": "actions",
				"restURL": "/actions/Office%20-%20Mood.json"
			}
			, {
				"name": "Office - Off",
				"nameURLEncoded": "Office%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Office%20-%20Off.json"
			}, 	{
				"name": "Cellar - Off",
				"nameURLEncoded": "Cellar%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Cellar%20-%20Off.json"
			}
			, {
				"name": "Cellar - On",
				"nameURLEncoded": "Cellar%20-%20On",
				"restParent": "actions",
				"restURL": "/actions/Cellar%20-%20On.json"
			}
			, {
				"name": "Conservatory - Off",
				"nameURLEncoded": "Conservatory%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Conservatory%20-%20Off.json"
			}
			, {
				"name": "Conservatory - On",
				"nameURLEncoded": "Conservatory%20-%20On",
				"restParent": "actions",
				"restURL": "/actions/Conservatory%20-%20On.json"
			}
			, {
				"name": "Joe - Bright",
				"nameURLEncoded": "Joe%20-%20Bright",
				"restParent": "actions",
				"restURL": "/actions/Joe%20-%20Bright.json"
			}
			, {
				"name": "Joe - Mood",
				"nameURLEncoded": "Joe%20-%20Mood",
				"restParent": "actions",
				"restURL": "/actions/Joe%20-%20Mood.json"
			}
			, {
				"name": "Joe - Off",
				"nameURLEncoded": "Joe%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Joe%20-%20Off.json"
			}
			, {
				"name": "Utility - Off",
				"nameURLEncoded": "Utility%20-%20Off",
				"restParent": "actions",
				"restURL": "/actions/Utility%20-%20Off.json"
			}
			, {
				"name": "Utility - On",
				"nameURLEncoded": "Utility%20-%20On",
				"restParent": "actions",
				"restURL": "/actions/Utility%20-%20On.json"
			}
		]
		@scenes = @getScenes(testActions)
		@scenes.sort @sortByRoomName
		@dataReadyCallback(@serverDef.name, @scenes)
		return

	sortByRoomName: (a, b) ->
		if a.groupName < b.groupName then return -1
		if a.groupName > b.groupName then return 1
		return 0

	getScenes: (data, rooms) ->
		indigoScenes = data
		scenes = []
		for indigoScene in indigoScenes
			name = indigoScene.name.split(" - ")
			actionName = indigoScene.name
			if name.length > 1
				roomName = name[0].trim()
				actionName = name[1].trim()
			scene = 
				actionNum: ""
				actionName: roomName + " " + actionName
				groupName: roomName
				actionUrl: @serverDef.url + "/actions/" + indigoScene.nameURLEncoded + "?_method=execute"
				iconName: @manager.getIconFromActionName(actionName, @serverDef.iconAliasing)
			scenes.push(scene)
		return scenes

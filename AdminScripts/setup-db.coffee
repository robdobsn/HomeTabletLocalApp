MongoClient = require('mongodb').MongoClient
Server = require('mongodb').Server
fs = require('fs')
DefaultTabletConfig = require('../www/js/default-tablet-config.js')

# Mongo client
if process.argv[2]?
	if process.argv[2] is "localhost"
		mongoUrl = 'mongodb://localhost:27017/WallTablets'
	else
		mongoUrl = process.argv[2]
else
	mongoUrl = 'mongodb://macallan:27017/WallTablets'
console.log "Mongo database is " + mongoUrl

# Sonos Server URL
sonosServerUrl = 'http://macallan:5005'

replaceAll = (find, replace, str) ->
	str.replace new RegExp(find, 'g'), replace

console.log 'Setting Tablet Configuration from folder'
console.log  __dirname + '/tablets'
console.log()

MongoClient.connect mongoUrl, (err, db) ->
	if !db
		console.error 'Error! MongoDB must be running ... Shutting down'
		process.exit 1
	configsToSet = { count: 0 }
	# Get the default config
	defaultTabletConfig = new DefaultTabletConfig()
	configSettingsToGet =
		showCalServerButton: true
		showEnergyServerButton: true
		calServerUrl: "http://macallan:5077/calendar/min/45"
		energyServerUrl: "http://macallan:5098"
	commonConfig = defaultTabletConfig.get(configSettingsToGet)
	# Get the list of tablets from the configuration
	deviceConfigList = getDeviceConfigList()
	# Get Sonos/Blinds/Door configs
	doorActions = getDoorActions()
	sonosConfig = getSonosConfig(deviceConfigList)
	blindsActions = getBlindsActions()
	# Add blinds and sonos actions to common config
	for dAction in doorActions
		commonConfig.common.fixedActions.push dAction
	for bAction in blindsActions
		commonConfig.common.fixedActions.push bAction
	for sAction in sonosConfig
		commonConfig.common.fixedActions.push sAction
	# Go through tablets (devices) that have config info
	for devConf in deviceConfigList
		# Add in the favourites and other info like tablet name
		newConfig = {}
		for key,val of devConf
			newConfig[key] = val
		# Set the common configuration for all tablets
		newConfig["common"] = commonConfig.common
		newConfig.common["servers"] = getServerList()
		setConfigInDb db, newConfig, configsToSet, devConf.favourites
	return

setConfigInDb = (configDb, deviceConfig, configsToSet, favourites) ->
	configDb.collection('TabletConfig').findOne { 'deviceName': deviceConfig['deviceName'] },
		(err, doc) ->
			# console.log("current doc " + JSON.stringify(doc))
			curFavourites = []
			if doc? and doc.favourites?
				curFavourites = doc.favourites
			# Merge favourites - adding only distinct ones
			favsToAdd = []
			for curFav in curFavourites
				addThis = true
				for newFav in deviceConfig["favourites"]
					if curFav.tileName is newFav.tileName and curFav.groupName is newFav.groupName
						addThis = false
						break
				if addThis
					favsToAdd.push curFav
			for fav in favsToAdd
				deviceConfig["favourites"].push fav
			# Set the new config
			configsToSet.count++
			# console.log "++ " + configsToSet.count
			configDb.collection('TabletConfig').update { 'deviceName': deviceConfig['deviceName'] },
				deviceConfig, {upsert:true}, (err, numberOfRemovedDocs) ->
					if err isnt null
						console.log 'Failed to save new info ' + err
						configDb.close()
						process.exit 1
					else
						configsToSet.count--
						# console.log "-- " + configsToSet.count
						if configsToSet.count is 0
							console.log 'All config set'
							configDb.close()
							process.exit 1
					return
			return
	return

getSonosConfig = (deviceConfigList) ->
	sonosConfig = []
	for deviceConfig, confIdx in deviceConfigList
		sonosRoomName = deviceConfig['sonosRoomName']
		roomName = deviceConfig['roomName']
		# Add sonos config if there is a sonos device in the room
		if deviceConfig['sonosRoomName'] is ''
			confIdx++
			continue
		actionConfig = [
			{
			'actionName': 'Play'
			'iconName': 'music-play'
			'uri': '/play'
			}
			{
			'actionName': 'Stop'
			'iconName': 'music-stop'
			'uri': '/pause'
			}
			{
			'actionName': 'Vol +'
			'iconName': 'music-vol-up'
			'uri': '/volume/+10'
			}
			{
			'actionName': 'Vol -'
			'iconName': 'music-vol-down'
			'uri': '/volume/-10'
			}
		]
		# Add the serverpath and tile info
		for act in actionConfig
			act['actionUrl'] = sonosServerUrl + '/' + sonosRoomName + act['uri']
			act['uri'] = sonosServerUrl + '/' + sonosRoomName + act['uri']
			act['groupName'] = roomName
			act['tierName'] = 'sonosTier'
			act['colSpan'] = 1
			act['rowSpan'] = 1
			act['name'] = act['actionName']
			act['visibility'] = 'all'
			act['tileType'] = 'Sonos'
			sonosConfig.push act
		# console.log("setting sonos actions config for " + sonosRoomName);
		confIdx++
	return sonosConfig

getBlindsActions = () ->
	blindsDef = 
		[
			[ "Games Room", [ ["1", "Shade 1"], ["2", "Shade 2"] ], "http://192.168.0.225/blind/"],
			[ "Grace Bath", [ ["1", "Shade"] ], "http://192.168.0.226/blind/" ],
			[ "Office", [ ["1", "Rob's Shade"], ["2", "Left"], ["3", "Mid-Left"], ["4", "Mid-Right"], ["5", "Right"] ], "http://192.168.0.220/blind/"]
		]
	return genBlindsActions(blindsDef)

genBlindsActions = (blindsDefs) ->
	blindsDirns = [ ["Up", "up"], ["Stop","stop"], ["Down","down"] ]
	actions = []
	for room in blindsDefs
		for dirn in blindsDirns
			for win in room[1]
				actions.push { tierName: "doorBlindsTier", actionNum: 0, actionName: win[1] + " " + dirn[0], groupName: room[0], actionUrl: room[2] + win[0] + "/" + dirn[1] + "/pulse", iconName: "blinds-" + dirn[1] }
	return actions

getDoorActions = () ->
	return [
			{ actionName: "Main Unlock", groupName: "Front Door", actionUrl: "http://192.168.0.221/main-unlock", iconName: "door-unlock" }
			{ actionName: "Main Lock", groupName: "Front Door", actionUrl: "http://192.168.0.221/main-lock", iconName: "door-lock" }
			{ actionName: "Inner Unlock", groupName: "Front Door", actionUrl: "http://192.168.0.221/inner-unlock", iconName: "door-unlock" }
			{ actionName: "Inner Lock", groupName: "Front Door", actionUrl: "http://192.168.0.221/inner-lock", iconName: "door-lock" }
		]

getDeviceConfigList = (configDb) ->
	deviceInfoList = []
	# Get contents of folder to find device definition files
	baseFolder = './tablets/'
	folderList = fs.readdirSync(baseFolder)
	fIdx = 0
	while fIdx < folderList.length
		if folderList[fIdx].indexOf('.json') > 0
			jsonStr = fs.readFileSync(baseFolder + folderList[fIdx], encoding: 'utf8')
			jsonStr = replaceAll('@sonosServerUrl', sonosServerUrl, jsonStr)
			devInfo = JSON.parse(jsonStr)
			deviceInfoList.push devInfo
		fIdx++
	return deviceInfoList

getServerList = () ->
	return [
			{"type":"indigo", "name":"IndigoUp", "url":"http://IndigoServer.local:8176", "iconAliasing":"automationIcons" },
			{"type":"indigo", "name":"IndigoDown", "url":"http://IndigoDown.local:8176", "iconAliasing":"automationIcons"  },
			# {"type":"indigo-test", "name":"IndigoTest", "url":"", "iconAliasing":"automationIcons"  },
			# {"type":"fibaro", "name":"FibaroHS2", "url":"http://macallan:5079" },
			# {"type":"vera", "name":"Vera", "url":"http://192.168.0.206:3480" },
			# {"type":"intermediate", "name":"intermediate", "url":"http://macallan:5000" },
		]

getCommonTabletConfig = () ->
	tabConfig =
		servers:
			[
				# {"type":"indigo", "name":"IndigoUp", "url":"http://IndigoServer.local:8176", "iconAliasing":"automationIcons" },
				# {"type":"indigo", "name":"IndigoDown", "url":"http://IndigoDown.local:8176", "iconAliasing":"automationIcons"  },
				{"type":"indigo-test", "name":"IndigoTest", "url":"", "iconAliasing":"automationIcons"  },
				# {"type":"calendar", "name":"Calendar", "url":"http://macallan:5077/calendar/min/31" },
				# {"type":"fibaro", "name":"FibaroHS2", "url":"http://macallan:5079" },
				# {"type":"vera", "name":"Vera", "url":"http://192.168.0.206:3480" },
				# {"type":"intermediate", "name":"intermediate", "url":"http://macallan:5000" },
			]
		calendar:
			"url":"http://localhost:5077/calendar/min/31"
			"numDays":31
		fixedActions:
			[
				{ actionName: "Main Unlock", groupName: "Front Door", actionUrl: "http://192.168.0.221/main-unlock", iconName: "door-unlock" }
				{ actionName: "Main Lock", groupName: "Front Door", actionUrl: "http://192.168.0.221/main-lock", iconName: "door-lock" }
				{ actionName: "Inner Unlock", groupName: "Front Door", actionUrl: "http://192.168.0.221/inner-unlock", iconName: "door-unlock" }
				{ actionName: "Inner Lock", groupName: "Front Door", actionUrl: "http://192.168.0.221/inner-lock", iconName: "door-lock" }
			]
		iconAliasing:
			automationIcons:
				[
					{ regex: "^Off$", iconName: "bulb-off"}
					{ regex: "^On$", iconName: "bulb-on"}
					{ regex: "^Bright$", iconName: "bulb-on"}
					{ regex: "^Mood", iconName: "bulb-mood"}
					{ regex: "^Stars", iconName: "stars"}
				]
		pages: 
			"Home":
				defaultPage: true
				pageName: "Home"
				pageTitle: "Home"
				columns: 
					landscape: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				tilesFixed: [
					{ "tileType": "clock", "tileName": "Clock", "groupName": "Clock", "positionCue": "end", "rowSpan": 2, "colSpan": 2 },
					{ "tileType": "nav", "tileName": "Rooms", "colType":"nav", "iconName": "floorplan", "tileText": "", "url": "Rooms", "iconX":"centre" }
					{ "tileType": "nav", "tileName": "Calendar", "colType":"nav", "iconName": "calendar", "tileText": "", "url": "Calendar", "iconX":"centre" }
					{ "tileType": "nav", "tileName": "Energy", "colType":"nav", "iconName": "energy", "tileText": "", "url": "Energy", "iconX":"centre" }
					{ "tileType": "nav", "tileName": "Settings", "colType":"nav", "iconName": "config", "tileText": "", "url": "Settings", "iconX":"centre" }
				]
				tileGen: [
					{ "tabConfigFavListName":"favourites", "tileType": "action", "tileSelect":"groupName", "tileMult": "all", "tileSort": "tileText", "tileNameFrom": "actionName", "tileTextFrom":"actionName", "urlFrom": "actionUrl", "rowSpan": 1, "colSpan": 2 }
				]
			"Rooms": 
				pageName: "Rooms"
				pageTitle: "Rooms"
				columns:
					landscape: [
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				tileGen: [ 
					{ "tileType": "action", "colType": "", "tileSelect":"groupName", "tileMult": "unique", "tileSort": "groupName", "tileNameFrom": "groupName", "tileTextFrom":"groupName", "pageGenRule": "RoomPages", "urlFrom": "groupName", "iconName": "" }
				]
				tilesFixed: [
					{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "", "url": "Home", "iconX":"centre" }
				]
			"Calendar": 
				pageName: "Calendar"
				pageTitle: "Calendar"
				columns:
					landscape: [
						{ "title": "", "colSpan": 4 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				tilesFixed: [
					{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "", "url": "Home", "iconX":"centre" }
					{ "tileType": "nav", "tileName": "Next", "colType":"nav", "iconName": "arrow-right", "tileText": "", "url": "~Calendar?next", "iconX":"centre" }
					{ "tileType": "nav", "tileName": "Prev", "colType":"nav", "iconName": "arrow-left", "tileText": "", "url": "~Calendar?prev", "iconX":"centre" }
					{ "tileType": "calendar", "tileName": "Calendar", "groupName": "Calendar", "rowSpan": 0, "colSpan": 0 }
				]
			"Energy":
				pageName: "Energy"
				pageTitle: "Energy"
				columns:
					landscape: [
						{ "title": "", "colSpan": 4 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				tilesFixed: [
					{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "", "url": "Home", "iconX":"centre" }
					{ "tileType": "iframe", "tileName": "EnergyWidget", "groupName": "Energy", "contentUrl":"http://www.w3schools.com", "rowSpan": 0, "colSpan": 0  }
				]

			"Settings":
				pageName: "Settings"
				pageTitle: "Settings"
				columns:
					landscape: [
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				rows:
					landscape: 7
					portrait: 12
				tilesFixed: [
					{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "", "url": "Home", "iconX":"centre", "forceReloadPages": true }
					{ "tileName": "Favourites", "groupName": "Settings", "tileText":"Set Favourites", "rowSpan": 1, "colSpan": 2, "url": "FavsSelect", "iconName":"star", "pageGenRule": "FavsSelectPage"  }
					{ "tileName": "Dim", "groupName": "Settings", "tileText":"Dim Display Now", "rowSpan": 1, "colSpan": 2, "url": "DimDisplay", "iconName":"dim" }
					{ "tileType": "checkbox", "tileName": "AutoDim", "groupName": "Settings", "tileText":"AutoDim Display", "rowSpan": 1, "colSpan": 2, "url": "~AutoDim?toggle", "iconName":"checked", "iconNameOff":"unchecked", "varName":"AutoDim" }
					{ "tileType": "textentry", "tileName": "ConfigServer", "groupName": "Settings", "rowSpan": 1, "colSpan": 2, "label":"Cfg URL ", "contentType":"url", "varName":"ConfigServerUrl", "clickFn":"" }
					{ "tileType": "textentry", "tileName": "TabletName", "groupName": "Settings", "rowSpan": 1, "colSpan": 2, "label":"TabName ", "contentType":"devname", "varName":"DeviceConfigName", "clickFn":"" }
				]
			"DimDisplay":
				pageName: "Dim"
				pageTitle: "Dim"
				columns:
					landscape: [
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				tilesFixed: [
					{ "tileType": "nav", "tileName": "Home", "colType":"nav", "tileText": "", "url": "Home", "rowSpan":0, "tileColour":"black" }
				]
			"FavSelectRoom": 
				pageName: "FavSelectRooms"
				pageTitle: "Select Room"
				columns:
					landscape: [
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				tileGen: [ 
					{ "tileType": "action", "colType": "", "tileSelect":"groupName", "tileMult": "unique", "tileSort": "groupName", "tileNameFrom": "groupName", "tileTextFrom":"groupName", "pageGenRule": "RoomPages", "urlFrom": "groupName", "iconName": "", "pageMode":"SelFavs" }
				]
				tilesFixed: [
					{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "", "url": "Home" }
				]
		pageGen: 
			"RoomPages" :
				"pageNameFrom": "tileText"
				"pageTitleFrom": "tileText"
				"tileModeFrom": "pageMode"
				columns:
					landscape: [
						{ "title": "", "titleGen":"pageName", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "titleGen":"pageName", "colSpan": 1 },
						{ "title": "", "colSpan": 1 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				tilesFixed: [
					{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "", "url": "Home", "iconX":"centre" }
				]
				tileGen: [ 
					{ "tileType": "action", "colType": "", "tileSelect":"groupName", "tileMult": "all", "tileFilterValFrom":"pageName", "tileSort": "tileName", "tileNameFrom": "actionName", "tileTextFrom":"actionName", "urlFrom": "actionUrl" }
				]
			"FavsSelectPage" :
				"pageName": "Set Favourites"
				"pageTitle": "Set Favourites"
				columns: 
					landscape: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					portrait: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
				tilesFixed: [
					{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "", "url": "Home", "iconX":"centre" }
					{ "tileType": "action", "tileName": "Add Fav", "colType":"nav", "tileText": "Add", "url": "FavSelectRoom", "iconName":"add" }
				]
				tileGen: [
					{ "tabConfigFavListName":"favourites", "tileType": "action", "tileSelect":"groupName", "tileMult": "all", "tileSort": "tileText", "tileNameFrom": "actionName", "tileTextFrom":"actionName", "url": "DelFav", "rowSpan": 1, "colSpan": 2, "iconName":"delete" }
				]

	return tabConfig
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


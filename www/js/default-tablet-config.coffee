class DefaultTabletConfig

	get: (serverSettings, additionalSettings) ->
		# Add the basic pages
		tabConfig = 
			common:
				servers: []
				fixedActions: []
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
							landscape: 10
							portrait: 14
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

		# Add additional settings for automation servers as required
		for autServ, servIdx in serverSettings.showAutomationServerSettings
			tabConfig.common.pages["Settings"].tilesFixed.push
				"tileType": "textentry"
				"tileName": "AutServer" + servIdx
				"groupName": "Settings"
				"rowSpan": 1
				"colSpan": 2
				"label": autServ + " "
				"contentType":"url"
				"varName": autServ + "ServerUrl"
				"clickFn":""

		# Add automation servers if we have URLs for them
		for autServ, servIdx in serverSettings.showAutomationServerSettings
			servUrl = LocalStorage.get(autServ + "ServerUrl")
			if servUrl? and servUrl isnt ""
				tabConfig.common.servers.push
					"type":autServ
					"name":autServ
					"url":servUrl
					"iconAliasing":"automationIcons"

		# Add additional settings for calendar server as required
		if serverSettings.showCalServerSetting
			tabConfig.common.pages["Settings"].tilesFixed.push
				"tileType": "textentry"
				"tileName": "CalServer"
				"groupName": "Settings"
				"rowSpan": 1
				"colSpan": 2
				"label":"CalServer "
				"contentType":"url"
				"varName":"CalServerUrl"
				"clickFn":""

		# Add calendar server and home page button if we have a URL for it
		calServerUrl = LocalStorage.get("CalServerUrl")
		if calServerUrl? and calServerUrl isnt ""
			tabConfig.common.calendar =
				"url": calServerUrl
				"numDays":90
			tabConfig.common.pages["Home"].tilesFixed.push
				"tileType": "nav"
				"tileName": "Calendar"
				"colType":"nav"
				"iconName": "calendar"
				"tileText": ""
				"url": "Calendar"
				"iconX":"centre"

		# Energy server settings
		if serverSettings.showEnergyServerSetting
			tabConfig.common.pages["Settings"].tilesFixed.push
				"tileType": "textentry"
				"tileName": "EnergyServer"
				"groupName": "Settings"
				"rowSpan": 1
				"colSpan": 2
				"label":"EnergyUrl "
				"contentType":"url"
				"varName":"EnergyServerUrl"
				"clickFn":""

		# Add energy server tile on energy page and home page button if we have a URL for it
		energyServerUrl = LocalStorage.get("EnergyServerUrl")
		if energyServerUrl? and energyServerUrl isnt ""
			tabConfig.common.pages["Energy"].tilesFixed.push
				"tileType": "iframe"
				"tileName": "EnergyWidget"
				"groupName": "Energy"
				"contentUrl": energyServerUrl
				"rowSpan": 0
				"colSpan": 0
			tabConfig.common.pages["Home"].tilesFixed.push
				"tileType": "nav"
				"tileName": "Energy"
				"colType":"nav"
				"iconName": "energy"
				"tileText": ""
				"url": "Energy"
				"iconX":"centre"

		# Add any additional settings
		if additionalSettings?
			for key,val of additionalSettings
				if key is "common"
					for comKey, comVal in val
						if comKey is "pages" or comKey is "pageGen"
							for pagKey, pagVal in comVal
								# Overwrite page definitions
								tabConfig.common[comKey][pagKey] = pagVal
						else if comKey is "servers"
							# Add servers
							tabConfig.common.servers.push(comVal)
						else if comKey is "fixedActions"
							# Add to fixed actions
							tabConfig.common.fixedActions.push(comVal)
						else
							tabConfig.common[comKey] = comVal
				# Add other settings
				tabConfig[key] = val

		return tabConfig


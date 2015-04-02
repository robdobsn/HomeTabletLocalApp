class AppPages
	constructor: (@parentTag, @defaultActionFn, @mediaPlayHelper) ->
		@curPage = { "pageName": "" }
		@tabletConfig = {}
		@generatedPage = {}

	setCurrentPage: (pageName, forceSet) ->
		if @tabletConfig.common? and @tabletConfig.common.pages?
			if pageName of @tabletConfig.common.pages
				if forceSet or (@curPage.pageName isnt pageName)
					@curPage = @tabletConfig.common.pages[pageName]
					return true
			else if forceSet or (@generatedPage.pageName? and @generatedPage.pageName is pageName)
				@curPage = @generatedPage
				return true
		return false

	build: (@tabletConfig, @automationActionGroups) ->
		# console.log JSON.stringify(tabletConfig.getConfigData())
		# console.log JSON.stringify(automationActionGroups)

		# @tabletConfig = 
		# common:
		# 	pages: 
		# 		"Home":
		# 			defaultPage: true
		# 			pageName: "Home"
		# 			pageTitle: "Home"
		# 			columns: 
		# 				landscape: [ 
		# 					{ "title": "", "colSpan": 2 },
		# 					{ "title": "", "colSpan": 2 },
		# 					{ "title": "", "colSpan": 1, "colType": "nav" }
		# 				]
		# 				portrait: [ 
		# 					{ "title": "", "colSpan": 2 },
		# 					{ "title": "", "colSpan": 1, "colType": "nav" }
		# 				]
		# 			tilesFixed: [
		# 				{ "tileType": "clock", "tileName": "Clock", "groupName": "Clock", "positionCue": "end", "rowSpan": 2, "colSpan": 2 },
		# 				{ "tileType": "nav", "tileName": "Rooms", "colType":"nav", "iconName": "floorplan", "tileText": "Rooms", "url": "Rooms" }
		# 				{ "tileType": "nav", "tileName": "Music", "colType":"nav", "iconName": "musicicon", "tileText": "Music" }
		# 				{ "tileType": "nav", "tileName": "Calendar", "colType":"nav", "iconName": "calendar", "tileText": "Events", "url": "Calendar" }
		# 				{ "tileType": "nav", "tileName": "Energy", "colType":"nav", "iconName": "energy", "tileText": "Energy" }
		# 				{ "tileType": "nav", "tileName": "Settings", "colType":"nav", "iconName": "config", "tileText": "Settings" }
		# 			]
		# 			tileGen: [
		# 				{ "tileFilterVal":"Grace", "tileNameSelect":"Grace Off", "tileType": "action", "tileSelect":"groupName", "tileMult": "all", "tileSort": "tileText", "tileNameFrom": "actionName", "tileTextFrom":"actionName", "urlFrom": "actionUrl", "rowSpan": 1, "colSpan": 2 }
		# 			]
		# 		"Rooms": 
		# 			pageName: "Rooms"
		# 			pageTitle: "Rooms"
		# 			columns:
		# 				landscape: [
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1, "colType": "nav" }
		# 				]
		# 				portrait: [ 
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1, "colType": "nav" }
		# 				]
		# 			tileGen: [ 
		# 				{ "tileType": "action", "colType": "", "tileSelect":"groupName", "tileMult": "unique", "tileSort": "groupName", "tileNameFrom": "groupName", "tileTextFrom":"groupName", "pageGenRule": "RoomPages", "urlFrom": "groupName", "iconName": "" }
		# 			]
		# 			tilesFixed: [
		# 				{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "Home", "url": "Home" }
		# 				{ "tileType": "nav", "tileName": "Music", "colType":"nav", "iconName": "musicicon", "tileText": "Music" }
		# 				{ "tileType": "nav", "tileName": "Calendar", "colType":"nav", "iconName": "calendar", "tileText": "Calendar", "url": "Calendar" }
		# 				{ "tileType": "nav", "tileName": "Settings", "colType":"nav", "iconName": "config", "tileText": "Settings" }
		# 				{ "tileType": "nav", "tileName": "Energy", "colType":"nav", "iconName": "energy", "tileText": "Energy" }
		# 			]
		# 		"Calendar": 
		# 			pageName: "Calendar"
		# 			pageTitle: "Calendar"
		# 			columns:
		# 				landscape: [
		# 					{ "title": "", "colSpan": 4 },
		# 					{ "title": "", "colSpan": 1, "colType": "nav" }
		# 				]
		# 				portrait: [ 
		# 					{ "title": "", "colSpan": 2 },
		# 					{ "title": "", "colSpan": 1, "colType": "nav" }
		# 				]
		# 			tilesFixed: [
		# 				{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "Home", "url": "Home" }
		# 				{ "tileType": "calendar", "tileName": "Calendar", "groupName": "Calendar", "rowSpan": 8, "colSpan": 4 }
		# 			]
		# 	pageGen: 
		# 		"RoomPages" :
		# 			"pageNameFrom": "tileText"
		# 			"pageTitleFrom": "tileText"
		# 			columns:
		# 				landscape: [
		# 					{ "title": "", "titleGen":"pageName", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1, "colType": "nav" }
		# 				]
		# 				portrait: [ 
		# 					{ "title": "", "titleGen":"pageName", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1 },
		# 					{ "title": "", "colSpan": 1, "colType": "nav" }
		# 				]
		# 			tilesFixed: [
		# 				{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "Home", "url": "Home" }
		# 			]
		# 			tileGen: [ 
		# 				{ "tileType": "action", "colType": "", "tileSelect":"groupName", "tileMult": "all", "tileFilterValFrom":"pageName", "tileSort": "tileName", "tileNameFrom": "actionName", "tileTextFrom":"actionName", "urlFrom": "actionUrl" }
		# 			]

		# console.log JSON.stringify(@tabletConfig)

		# Generate pages from data
		if @tabletConfig.common? and @tabletConfig.common.pages?
			for pageName, pageDef of @tabletConfig.common.pages
				if pageDef.defaultPage? and pageDef.defaultPage
					@setCurrentPage(pageName, true)
				pageDef.tiles = []
				if pageDef.tilesFixed?
					for tile in pageDef.tilesFixed
						pageDef.tiles.push tile
				@generatePageContents(pageDef, @tabletConfig)

	generatePageContents: (pageDef, tabletSpecificConfig) ->
		tileList = []
		uniqList = []
		# Tile generators provide metadata to allow tiles to be constructed from
		# tilesources like indigo/fibaro/vera/sonos/blind/door controllers
		if "tileGen" of pageDef
			for tileGen in pageDef.tileGen
				# Allow a specific tile source to be specified - otherwise all sources are used
				sourceList = []
				if "tileSources" of tileGen
					sourceList = (source for source in tileGen.tileSources)
				else
					sourceList = (source for source, val of @automationActionGroups)
				for tileSource in sourceList
					# Check this tilesource exists
					if tileSource of @automationActionGroups
						# Iterate tiles in the tile source
						for tile in @automationActionGroups[tileSource]
							# Tiles can be selected either specifically or using data
							# from the tablet configuration - such as favourites
							if tileGen.tileSelect of tile
								newTile = {}
								for key, val of tile
									newTile[key] = val
								newTile.tileType = tileGen.tileType
								newTile.tileName = tile[tileGen.tileNameFrom]
								newTile.colType = if tileGen.colType? then tileGen.colType else ""
								newTile.url = tile[tileGen.urlFrom]
								if tileGen.pageGenRule?
									newTile.pageGenRule = tileGen.pageGenRule
								if tileGen.rowSpan?
									newTile.rowSpan = tileGen.rowSpan
								if tileGen.colSpan?
									newTile.colSpan = tileGen.colSpan								
								newTile.tileText = tile[tileGen.tileTextFrom]
								if "iconName" of tileGen
									newTile.iconName = tileGen.iconName
								# The tileMult "unique" is used to select a single tile from
								# a tile group - this is for creating menu listing rooms, etc
								if tileGen.tileMult is "unique"
									if newTile[tileGen.tileSelect] not in uniqList
										tileList.push newTile
										uniqList.push newTile[tileGen.tileSelect]
								# Handle generation of pages for a specific group - e.g. a specific room menu
								else if "tileFilterValFrom" of tileGen
									if newTile[tileGen.tileSelect] is pageDef[tileGen.tileFilterValFrom]
										tileList.push newTile								# Select a single specific tile but using data from the tabled config
								# such as the favourites list - e.g. using the groupname (room) and
								# tilename (action) to get a favourite tile
								else if "tabConfigFavListName" of tileGen
									for favList in tabletSpecificConfig[tileGen.tabConfigFavListName]
										if newTile[tileGen.tileSelect] is favList[tileGen.tileSelect]
											if newTile.tileName is favList.tileName
												tileList.push newTile
								# Only select a single specific tile explicitly named in the pageDef
								# e.g. using the specific groupname (room) and tilename (action)
								else if "tileFilterVal" of tileGen
									if newTile[tileGen.tileSelect] is tileGen.tileFilterVal
										if "tileNameSelect" of tileGen
											if newTile.tileName is tileGen.tileNameSelect
												tileList.push newTile
										else
											tileList.push newTile
								else
									tileList.push newTile
			tileList.sort (a,b) =>
				if a[tileGen.tileSort] < b[tileGen.tileSort] then return -1
				if a[tileGen.tileSort] > b[tileGen.tileSort] then return 1
				return 0
			if uniqList.length > 0
				console.log "UNIQLIST " + JSON.stringify(uniqList)
			else
				console.log "TILELIST " + JSON.stringify(tileList)
			for tile in tileList
				pageDef.tiles.push tile
		return pageDef

	generateNewPage: (context) ->
		if context.pageGenRule? and context.pageGenRule isnt ""
			if context.pageGenRule of @tabletConfig.common.pageGen
				pageGen = @tabletConfig.common.pageGen[context.pageGenRule]
				@generatedPage =
					"pageName": context[pageGen.pageNameFrom]
					"pageTitle": context[pageGen.pageTitleFrom]
					"columns": pageGen.columns
					"tiles": (tile for tile in pageGen.tilesFixed)
					"tileGen": (tileGen for tileGen in pageGen.tileGen)
				for col in @generatedPage.columns.landscape
					if col.titleGen?
						col.title = @generatedPage[col.titleGen]
				for col in @generatedPage.columns.portrait
					if col.titleGen?
						col.title = @generatedPage[col.titleGen]
				@generatePageContents(@generatedPage, @tabletConfig)
				return @generatedPage.pageName
		return ""

	display: ->
		newPage = new TabPage(@parentTag, @curPage, @buttonCallback)
		newPage.updateDom()

	buttonCallback: (context) =>
		console.log "Pressed " + JSON.stringify(context)
		# Check for navigation button
		if "/" in context.url
			(@defaultActionFn) context.url
		else
			if @setCurrentPage(context.url, false)
				@display()
			else
				console.log "Attempting page generation " + context.url
				newPageName = @generateNewPage(context)
				@setCurrentPage(newPageName, false)
				@display()
		return

	playClickSound: ->
		@mediaPlayHelper.play("click")
		return

    # addTileToTierGroup: (tileDef, tile) ->
    #     tierName = tileDef.tierName
    #     groupName = tileDef.groupName
    #     groupPriority = if "groupPriority" of tileDef then tileDef.groupPriority else 5
    #     tierIdx = @tileTiers.findTierIdx(tierName)
    #     if tierIdx < 0 then tierIdx = @tileTiers.findTierIdx("actionsTier")
    #     if tierIdx < 0 then return
    #     if groupName is "" then groupName = "Lights"
    #     groupIdx = @getUIGroupIdxAddGroupIfReqd(tierIdx, groupName, groupPriority)
    #     #groupIdx = @tileTiers.findGroupIdx(tierIdx, groupName)
    #     #if groupIdx < 0 then return
    #     @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)
    #     return

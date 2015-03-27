class AppPages
	constructor: (@parentTag, @defaultActionFn, @mediaPlayHelper) ->
		@curPage = { "pageName": "" }
		@tabletConfig = {}
		@generatedPage = {}

	setCurrentPage: (pageName, forceSet) ->
		if @tabletConfig.configData? and @tabletConfig.configData.pages?
			if pageName of @tabletConfig.configData.pages
				if forceSet or (@curPage.pageName isnt pageName)
					@curPage = @tabletConfig.configData.pages[pageName]
					return true
			else if forceSet or (@generatedPage.pageName? and @generatedPage.pageName is pageName)
				@curPage = @generatedPage
				return true
		return false

	build: (@tabletConfig, @automationActionGroups) ->
		# console.log JSON.stringify(tabletConfig.getConfigData())
		# console.log JSON.stringify(automationActionGroups)

		# @tabletConfig = 
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
		# 			tiles: [
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
		# 			tiles: [
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
		# 			tiles: [
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
		# 			tiles: [
		# 				{ "tileType": "nav", "tileName": "Home", "colType":"nav", "iconName": "home", "tileText": "Home", "url": "Home" }
		# 			]
		# 			tileGen: [ 
		# 				{ "tileType": "action", "colType": "", "tileSelect":"groupName", "tileMult": "all", "tileFilterValFrom":"pageName", "tileSort": "tileName", "tileNameFrom": "actionName", "tileTextFrom":"actionName", "urlFrom": "actionUrl" }
		# 			]

		# console.log JSON.stringify(@tabletConfig)

		# Generate pages from data
		for pageName, pageDef of @tabletConfig.configData.pages
			if pageDef.defaultPage? and pageDef.defaultPage
				@setCurrentPage(pageName, true)
			pageDef.tiles = []
			if pageDef.tilesFixed?
				for tile in pageDef.tilesFixed
					pageDef.tiles.push tile
			@generatePageContents(pageDef)

	generatePageContents: (pageDef) ->
		if "tileGen" of pageDef
			tileList = []
			uniqList = []
			for tileGen in pageDef.tileGen
				sourceList = []
				if "tileSources" of tileGen
					sourceList = (source for source in tileGen.tileSources)
				else
					sourceList = (source for source, val of @automationActionGroups)
				for tileSource in sourceList
					if tileSource of @automationActionGroups
						for tile in @automationActionGroups[tileSource]
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
								if tileGen.tileMult is "unique"
									if newTile[tileGen.tileSelect] not in uniqList
										tileList.push newTile
										uniqList.push newTile[tileGen.tileSelect]
								else if "tileFilterValFrom" of tileGen
									if newTile[tileGen.tileSelect] is pageDef[tileGen.tileFilterValFrom]
										tileList.push newTile
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
			if context.pageGenRule of @tabletConfig.configData.pageGen
				pageGen = @tabletConfig.configData.pageGen[context.pageGenRule]
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
				@generatePageContents(@generatedPage)
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

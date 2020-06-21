class App.AppPages
	constructor: (@app, @parentTag, @automationManager, @VERSION) ->
		@curPageDef = { "pageName": "" }
		@generatedPage = {}
		@defaultPageName = ""
		@curTabPage = null
		# Basic body for DOM
		$("body").prepend """
			<div id="sqWrapper">
			</div>
			"""

	userIsIdle: ->
		# Check for auto-dim
		autoDim = App.LocalStorage.get("AutoDim")
		if autoDim? and autoDim
			if @setCurrentPage("DimDisplay")
				@display()
				return
		# Return to home page
		if @curPageDef.pageName isnt @defaultPageName
			@setCurrentPage(@defaultPageName)
			@display()
		return

	setCurrentPage: (pageName, forceSet) ->
		tabConfig = @app.tabletConfigManager.getConfigData()
		if tabConfig.common? and tabConfig.common.pages?
			if pageName of tabConfig.common.pages
				if forceSet or (@curPageDef.pageName isnt pageName)
					@curPageDef = tabConfig.common.pages[pageName]
					return true
			else if forceSet or (@generatedPage.pageName? and @generatedPage.pageName is pageName)
				@curPageDef = @generatedPage
				return true
		return false

	build: (@automationActionGroups) ->
		@rebuild(true)
		return

	rebuild: (forceSetInitialPage) ->
		# Generate pages from data
		tabConfig = @app.tabletConfigManager.getConfigData()
		if tabConfig.common? and tabConfig.common.pages?
			for pageName, pageDef of tabConfig.common.pages
				if pageDef.defaultPage? and pageDef.defaultPage
					if forceSetInitialPage
						@setCurrentPage(pageName, true)
					@defaultPageName = pageName
				pageDef.tiles = []
				if pageDef.tilesFixed?
					for tile in pageDef.tilesFixed
						pageDef.tiles.push tile
				@generatePageContents(pageDef, tabConfig)
		return

	generatePageContents: (pageDef, tabletSpecificConfig) ->
		tileList = []
		uniqList = []
		# Tile generators provide metadata to allow tiles to be constructed from
		# tilesources like indigo/fibaro/vera/sonos/blind/door controllers
		if "tileGen" not of pageDef
			return

		# Go through tileGen requirements
		for tileGen in pageDef.tileGen

			# Check if a specific tile source is specified - otherwise all sources are used
			sourceList = []
			if "tileSources" of tileGen
				sourceList = (source for source in tileGen.tileSources when source of @automationActionGroups)
			else
				sourceList = (source for source, val of @automationActionGroups)

			# The tileMult "unique" is used to select a single tile from
			# a tile group - this is for creating menu listing rooms, etc
			if tileGen.tileMult is "unique"
				# Iterate tiles in the tile sources
				for tileSource in sourceList
					for tile in @automationActionGroups[tileSource]
						if tileGen.tileSelect of tile
							if tile[tileGen.tileSelect] not in uniqList
								newTile = @generateTileInfo(tileGen, tile)
								tileList.push newTile
								uniqList.push newTile[tileGen.tileSelect]
			# Handle generation of pages for a specific group - e.g. a specific room menu
			else if "tileFilterValFrom" of tileGen
				for tileSource in sourceList
					for tile in @automationActionGroups[tileSource]
						if tileGen.tileSelect of tile
							if tile[tileGen.tileSelect] is pageDef[tileGen.tileFilterValFrom]
								newTile = @generateTileInfo(tileGen, tile)
								tileList.push newTile
			# Select a single specific tile but using data from the tablet config
			# such as the favourites list - e.g. using the groupname (room) and
			# tilename (action) to get a favourite tile
			else if "tabConfigFavListName" of tileGen and tileGen.tabConfigFavListName of tabletSpecificConfig
				for favList in tabletSpecificConfig[tileGen.tabConfigFavListName]
					favFound = false
					for tileSource in sourceList
						for tile in @automationActionGroups[tileSource]
							if tileGen.tileSelect of tile
								if tile[tileGen.tileSelect] is favList[tileGen.tileSelect] and tile[tileGen.tileNameFrom] is favList.tileName
									newTile = @generateTileInfo(tileGen, tile)
									if "tileText" of favList
										newTile.tileText = favList.tileText
									tileList.push newTile
									favFound = true
									break
						if favFound
							break
			# Only select a single specific tile explicitly named in the pageDef
			# e.g. using the specific groupname (room) and tilename (action)
			else if "tileFilterVal" of tileGen
				for tileSource in sourceList
					for tile in @automationActionGroups[tileSource]
						if tileGen.tileSelect of tile
							if tile[tileGen.tileSelect] is tileGen.tileFilterVal
								if "tileNameSelect" of tileGen
									if tile[tileGenInfo.tileNameFrom] is tileGen.tileNameSelect
										newTile = @generateTileInfo(tileGen, tile)
										tileList.push newTile
								else
									newTile = @generateTileInfo(tileGen, tile)
									tileList.push newTile
			else
				for tileSource in sourceList
					for tile in @automationActionGroups[tileSource]
						newTile = @generateTileInfo(tileGen, tile)
						tileList.push newTile

		# Sort tiles if required
		if "tileSort" of tileGen
			tileList.sort (a,b) =>
				if a[tileGen.tileSort] < b[tileGen.tileSort] then return -1
				if a[tileGen.tileSort] > b[tileGen.tileSort] then return 1
				return 0
		for tile in tileList
			pageDef.tiles.push tile
		return

	generateTileInfo: (tileGenInfo, tile) ->
		# Tiles can be selected either specifically or using data
		# from the tablet configuration - such as favourites
		newTile = {}
		for key, val of tile
			newTile[key] = val
		newTile.tileType = tileGenInfo.tileType
		newTile.pageMode = if "pageMode" of tileGenInfo then tileGenInfo.pageMode else ""
		newTile.tileMode = if "tileMode" of tileGenInfo then tileGenInfo.tileMode else ""
		newTile.tileName = tile[tileGenInfo.tileNameFrom]
		newTile.colType = if tileGenInfo.colType? then tileGenInfo.colType else ""
		newTile.url = if "urlFrom" of tileGenInfo then tile[tileGenInfo.urlFrom] else (if "url" of tileGenInfo then newTile.url = tileGenInfo.url)
		if tileGenInfo.pageGenRule?
			newTile.pageGenRule = tileGenInfo.pageGenRule
		if tileGenInfo.rowSpan?
			newTile.rowSpan = tileGenInfo.rowSpan
		if tileGenInfo.colSpan?
			newTile.colSpan = tileGenInfo.colSpan
		newTile.tileText = tile[tileGenInfo.tileTextFrom]
		if "iconName" of tileGenInfo
			newTile.iconName = tileGenInfo.iconName
		return newTile

	generateNewPage: (context) ->
		tabConfig = @app.tabletConfigManager.getConfigData()
		if context.pageGenRule? and context.pageGenRule isnt ""
			if context.pageGenRule of tabConfig.common.pageGen
				pageGen = tabConfig.common.pageGen[context.pageGenRule]
				@generatedPage =
					"pageName": if "pageNameFrom" of pageGen then context[pageGen.pageNameFrom] else pageGen.pageName
					"pageTitle": if "pageTitleFrom" of pageGen then context[pageGen.pageTitleFrom] else pageGen.pageTitle
					"columns": pageGen.columns
					"tiles": (tile for tile in pageGen.tilesFixed)
					"tileGen": (tileGen for tileGen in pageGen.tileGen)
				if "tileModeFrom" of pageGen
					for tileGen in @generatedPage.tileGen
						tileGen.tileMode = context[pageGen.tileModeFrom]
				for col in @generatedPage.columns.landscape
					if col.titleGen?
						col.title = @generatedPage[col.titleGen]
				for col in @generatedPage.columns.portrait
					if col.titleGen?
						col.title = @generatedPage[col.titleGen]
				@generatePageContents(@generatedPage, tabConfig)
				return @generatedPage.pageName
		return ""

	display: ->
		@curTabPage = new App.TabPage(@app, @parentTag, @curPageDef, @buttonCallback)
		@curTabPage.updateDom()

	buttonCallback: (context) =>
		# console.log "buttonCallback user button pressed " + JSON.stringify(context) + "\nprevPage " + JSON.stringify(@curPageDef) + "\n"

		# Check if settings save required
		# console.log "app-pages buttonCallback prev pageName " + @curPageDef.pageName + " == settings " + (@curPageDef.pageName == "Settings") + " not null " + (@curPageDef?)
		# if (@curPageDef?) && (@curPageDef.pageName == "Settings")
		# 	# console.log "app-pages buttonCallback saving config"
		# 	@app.tabletConfigManager.saveDeviceConfig()

		# Force reload
		if context.forceReloadPages? and context.forceReloadPages
			@app.requestConfigData()

		# Check for navigation button
		if "tileMode" of context and context.tileMode is "SelFavs"
			@addFavouriteButton(context)
			@setCurrentPage(@defaultPageName, false)
			@display()
		else if "/" in context.url
			(@automationManager.executeCommand) context.url
		else if "~" in context.url
			if @curTabPage?
				@curTabPage.handlePageNav(context.url)
		else if @setCurrentPage(context.url, false)
			@display()
		else if context.url is "DelFav"
			@deleteFavouriteButton(context)
			@setCurrentPage(@defaultPageName, false)
			@display()
		else if context.url is "AppUpdate"
			@app.appUpdate()
		else if context.url is "ExitYes"
			navigator.app.exitApp()
		else if context.tileType is "clock"
			alert "App version " + @VERSION
		else
			console.log "app-pages Attempting page generation " + JSON.stringify(context)
			newPageName = @generateNewPage(context)
			@setCurrentPage(newPageName, false)
			@display()
		return

	addFavouriteButton: (context) ->
		@app.tabletConfigManager.addFavouriteButton(context)
		@rebuild(false)
		return

	deleteFavouriteButton: (context) ->
		@app.tabletConfigManager.deleteFavouriteButton(context)
		@rebuild(false)
		return


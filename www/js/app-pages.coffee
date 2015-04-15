class AppPages
	constructor: (@app, @parentTag, @automationManager) ->
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
		autoDim = LocalStorage.get("AutoDim")
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
								newTile.pageMode = if "pageMode" of tileGen then tileGen.pageMode else ""
								newTile.tileMode = if "tileMode" of tileGen then tileGen.tileMode else ""
								newTile.tileName = tile[tileGen.tileNameFrom]
								newTile.colType = if tileGen.colType? then tileGen.colType else ""
								newTile.url = if "urlFrom" of tileGen then tile[tileGen.urlFrom] else (if "url" of tileGen then newTile.url = tileGen.url)
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
										tileList.push newTile
								# Select a single specific tile but using data from the tabled config
								# such as the favourites list - e.g. using the groupname (room) and
								# tilename (action) to get a favourite tile
								else if "tabConfigFavListName" of tileGen and tileGen.tabConfigFavListName of tabletSpecificConfig
									for favList in tabletSpecificConfig[tileGen.tabConfigFavListName]
										if newTile[tileGen.tileSelect] is favList[tileGen.tileSelect]
											if newTile.tileName is favList.tileName
												if "tileText" of favList
													newTile.tileText = favList.tileText
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
			if "tileSort" of tileGen
				tileList.sort (a,b) =>
					if a[tileGen.tileSort] < b[tileGen.tileSort] then return -1
					if a[tileGen.tileSort] > b[tileGen.tileSort] then return 1
					return 0
			for tile in tileList
				pageDef.tiles.push tile
		return pageDef

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
		@curTabPage = new TabPage(@app, @parentTag, @curPageDef, @buttonCallback)
		@curTabPage.updateDom()

	buttonCallback: (context) =>
		# Check for navigation button
		if context.forceReloadPages? and context.forceReloadPages
			@app.requestConfigData()
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
		else 
			console.log "Attempting page generation " + context.url
			newPageName = @generateNewPage(context)
			@setCurrentPage(newPageName, false)
			@display()
		return

	addFavouriteButton: (context) ->
		@app.tabletConfigManager.addFavouriteButton(context)
		@rebuild(false)

	deleteFavouriteButton: (context) ->
		@app.tabletConfigManager.deleteFavouriteButton(context)
		@rebuild(false)


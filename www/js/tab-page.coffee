class App.TabPage
	constructor: (@app, @parentTag, @pageDef, @defaultActionFn) ->
		@tiles = []
		@titlesTopMargin = 60
		@titlesYPos = 10
		@pageBorders = [ 12, 5, 12, 15 ]
		@tileSepXPixels = 20
		@tileSepYPixels = 10
		@groupSepPixels = 10
		@pageId = "sqPage"
		@pageSelector = "#" + @pageId
		@pageTitleClass = "sqPageTitle"
		@pageTitleSelector = "." + @pageTitleClass
		@tilesClass = "sqTiles"
		@tileContainerClass = "sqTileContainer"
		@tilesSelector = '.' + @tileContainerClass
		@colTitleClass = "sqColTitle"
		@tilesColumns = 2 # Overridden in redolayout
		@nextTileIdx = 0
		@columnTypes = {}
		return

	handlePageNav: (pageNav) ->
		[_,tileName,navAction] = pageNav.match /\~(.*)\?(.*)/
		for tile in @tiles
			if tile.tileDef.tileName is tileName
				tile.handleAction(navAction)
				break
		return

	updateDom: ->
		@calcLayout()
		@removeAll()
		# Add to html in parent tag
		$(@parentTag).html """
			<div id="#{@pageId}" class="sqPage">
				<div class="#{@pageTitleClass}"/>
				<div class="#{@tilesClass}" style="height:100%;width:100%">
					<div class=#{@tileContainerClass} style="width:100%;display:block;zoom:1;">
					</div>
				</div>
			</div>
			"""
		# Titles
		if @columnsDef?
			for col, colIdx in @columnsDef
				title = col.title
				if title? and title isnt ""
					$(@pageTitleSelector).append """
						<div class="#{@colTitleClass} #{@colTitleClass}_#{colIdx}">#{title}
						</div>
						"""
				colXPos = @getColXPos(colIdx)
				@setTitlePositionCss(colIdx, colXPos, @titlesYPos, 100)
		# Tiles
		if @pageDef.tiles?
			for tileDef in @pageDef.tiles
				newTile = @makeTileFromTileDef(tileDef)
				tile = @addTileToPage(tileDef, newTile)
				[x,y,sizeX, sizeY] = @getCellPos(tile)
				tile.reposition(x,y,sizeX,sizeY)
		return
			
	removeAll: ->
		@nextTileIdx = 0
		@clearTiles()
		$("##{@pageId}").remove()
		return

	clearTiles: ->
		for tile in @tiles
			tile.removeFromDoc()
		@tiles = []
		return

	addTileToPage: (tileDef, tile) ->
		tile.addToDoc()
		@tiles.push tile
		return tile

	makeTileFromTileDef: (tileDef) ->
		# Ensure tileDef is clean
		tileDef = @tileDefCleanCheck(tileDef)
		#Make the tile
		if tileDef.tileType is "calendar"
			dayIdx = if tileDef.calDayIndex? then tileDef.calDayIndex else 0
			tile = new App.CalendarTile(@app, tileDef, dayIdx)
		else if tileDef.tileType is "clock"
			tile = new App.Clock(tileDef)
		else if tileDef.tileType is "iframe"
			tile = new App.IframeTile(tileDef)
		else if tileDef.tileType is "checkbox"
			tile = new App.CheckBoxTile(tileDef)
		else if tileDef.tileType is "textentry"
			tile = new App.TextEntryTile(tileDef)
		else
			tile = new App.SceneButton(tileDef)
		tile.setTileIndex(@nextTileIdx++)
		return tile

	tileDefCleanCheck: (tileDef) ->
		tileDef.parentTag = @tilesSelector
		if "tileColour" not of tileDef
			tileDef.tileColour = @app.tileColours.getNextColour()
		if "clickFn" not of tileDef
			tileDef.clickFn = @defaultActionFn
		if "colSpan" not of tileDef
			tileDef.colSpan = 1
		if "rowSpan" not of tileDef
			tileDef.rowSpan = 1
		if "url" not of tileDef
			tileDef.url = ""
		if "visibility" not of tileDef
			tileDef.visibility = "both"
		if "tileName" not of tileDef
			tileDef.tileName = ""
		if "tileText" not of tileDef
			tileDef.tileText = ""
		if "iconName" not of tileDef
			tileDef.iconName = ""
		if "positionCue" not of tileDef
			tileDef.positionCue = ""
		tileDef.tierIdx = 0
		tileDef.groupIdx = 0
		return tileDef

	getPageHeight: ->
		pageSel = $("##{@pageId}")
		return pageSel[0].clientHeight

	getPageTop: ->
		return 0

	calcLayout: ->
		winWidth = $(window).width()
		winHeight = $(window).height()
		isPortrait = (winWidth < winHeight)
		if isPortrait
			@baseColumnsDef = if @pageDef.columns? then @pageDef.columns.portrait else null
			@tilesDown = if @pageDef.rows? then @pageDef.rows.portrait else 15
			@tilesAcross = 2
			@columnsAcross = 2
		else
			@baseColumnsDef = if @pageDef.columns? then @pageDef.columns.landscape else null
			@tilesDown = if @pageDef.rows? then @pageDef.rows.landscape else 8
			@tilesAcross = 3
			@columnsAcross = 3
		@columnsDef = []
		if @baseColumnsDef?
			@columnsDef = (col for col in @baseColumnsDef)
		@noTitles = true
		# Check for auto-add columns
		autoAddColIdx = -1
		colsToAdd = 0
		for colDef, colIdx in @columnsDef
			if colDef.autoAdd? and colDef.autoAdd
				autoAddColIdx = colIdx
				numTilesInAutoCol = 0
				for tile in @pageDef.tiles
					if not (tile.colType? and colDef.colType and (tile.colType isnt colDef.colType))
						numTilesInAutoCol++
				colsToAdd = Math.floor(numTilesInAutoCol/@tilesDown + 0.5) - 2
				break
		if colsToAdd > 0
			colToCopy = @columnsDef[autoAddColIdx]
			for i in [0...colsToAdd]
				@columnsDef.splice(autoAddColIdx, 0, colToCopy)
		# Handle columns
		if @columnsDef?
			@tilesAcross = 0
			for colDef, colIdx in @columnsDef
				if colDef.title? and colDef.title isnt ""
					@noTitles = false
				colType = if colDef.colType? then colDef.colType else ""
				if colType not of @columnTypes
					@columnTypes[colType] = 
						frontTileCount: 0
						endTileCount: 0
						colStartIdx: colIdx
						colCount: 1
						colSpan: if colDef.colSpan? then colDef.colSpan else 1
				else
					@columnTypes[colType].colCount++
					@columnTypes[colType].colSpan+=if colDef.colSpan? then colDef.colSpan else 1
				@tilesAcross += colDef.colSpan
			@columnsAcross = @columnsDef.length
		else
			@columnTypes =
				"": 
					frontTileCount: 0
					endTileCount: 0
					colStartIdx: 0
					colCount: 1
		# Layout page
		@cellWidth = (winWidth - @pageBorders[1] - @pageBorders[3]) / @tilesAcross
		@cellHeight = (winHeight - @pageBorders[0] - @pageBorders[2] - (if @noTitles then 0 else @titlesTopMargin)) / @tilesDown
		@tileWidth = @cellWidth - @tileSepXPixels
		@tileHeight = @cellHeight - @tileSepYPixels
		$("##{@pageId}").css {
			"height": document.documentElement.clientHeight + "px"
			}
		return isPortrait

	getColXPos: (colIdx) ->
		xStart = @pageBorders[3]
		# Default if no columns specified
		cellX = xStart + colIdx * @cellWidth * 2
		# Work out from column def
		cellXIdx = 0
		for i in [0...colIdx]
			cellXIdx += if @columnsDef? and @columnsDef[i] then @columnsDef[i].colSpan else 1
		return xStart + cellXIdx * @cellWidth

	getTitlePos: () ->
		return [0, 10, "200%"]

	getGroupTitleWidth: () ->
		return 400

	getColInfo: (tile) ->

	getCellPos: (tile) ->
		colType = if tile.tileDef.colType? then tile.tileDef.colType else ""
		if colType of @columnTypes
			colInfo = @columnTypes[colType]
		else
			colInfo = @columnTypes[""]
		# Check for colSpan not specified
		if "colSpan" not of tile.tileDef or tile.tileDef.colSpan is 0
			colSpan = colInfo.colSpan
		else
			colSpan = tile.tileDef.colSpan
		# Check for rowSpan not specified
		if "rowSpan" not of tile.tileDef or tile.tileDef.rowSpan is 0
			rowSpan = @tilesDown
		else
			rowSpan = tile.tileDef.rowSpan
		# Check for special positioning cues
		if tile.tileDef.positionCue is "end"
			winWidth = $(window).width()
			winHeight = $(window).height()
			isPortrait = (winWidth < winHeight)
			if isPortrait
				colIdx = 1
				colSpan = 1
				rowIdx = @tilesDown - Math.floor(colInfo.endTileCount % @tilesDown) - rowSpan
				colInfo.endTileCount+=rowSpan
			else
				colIdx = colInfo.colStartIdx + colInfo.colCount - 1 - Math.floor(colInfo.endTileCount/@tilesDown)
				rowIdx = @tilesDown - Math.floor(colInfo.endTileCount % @tilesDown) - rowSpan
				colInfo.endTileCount+=rowSpan
		else
			colIdx = colInfo.colStartIdx + Math.floor(colInfo.frontTileCount / @tilesDown)
			rowIdx = Math.floor(colInfo.frontTileCount % @tilesDown)
			colInfo.frontTileCount+=rowSpan
		# Column position
		cellX = @getColXPos(colIdx)
		cellY = @pageBorders[0] + (if @noTitles then 0 else @titlesTopMargin) + rowIdx * @cellHeight
		# Size of tile in pixels		
		sizeX = @tileWidth * colSpan + (@tileSepXPixels * (colSpan-1))
		sizeY = @tileHeight * rowSpan + (@tileSepYPixels * (rowSpan-1))
		return [cellX, cellY, sizeX, sizeY]

	reDoLayout: ->
		return @calcLayout()

	getTilesAcrossScreen: ->
		return @tilesAcross

	setTitlePositionCss: (colIdx, posX, posY) ->
		$('.' + @colTitleClass + "_" + colIdx).css {
			"margin-left": posX + "px", 
			"margin-top": posY + "px",
			"display": "block",
			"position": "absolute"
			}
			# "font-size": fontScaling + "%",
		return

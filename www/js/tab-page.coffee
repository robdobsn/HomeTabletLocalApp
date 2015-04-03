class TabPage
	constructor: (@parentTag, @pageDef, @defaultActionFn) ->
		@tileColours = new TileColours
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
		@columnTypes = { "": { frontTileCount: 0, endTileCount: 0, colStartIdx: 0 } }
		return

	updateDom: ->
		@calcLayout()
		@removeAll()
		# Add to html in parent tag
		$(@parentTag).html """
			<div id="#{@pageId}" class="sqPage">
				<div class="#{@pageTitleClass}"/>
				<div class="#{@tilesClass}">
					<div class=#{@tileContainerClass} style="width:3000px;display:block;zoom:1;">
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
				colInfo = @columnTypes[col.colType]
				colXPos = @getColXPos(colIdx)
				@setTitlePositionCss(colIdx, colXPos, @titlesYPos, 100)
		# Tiles
		if @pageDef.tiles?
			for tileDef in @pageDef.tiles
				newTile = @makeTileFromTileDef(tileDef)
				tile = @addTileToPage(tileDef, newTile)
				[x,y,fontScale] = @getCellPos(tile)
				[sizeX, sizeY] = @getTileSize(tile)
				tile.reposition(x,y,sizeX,sizeY,fontScale)
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
			tile = new CalendarTile tileDef, @calendarUrl, tileDef.calDayIndex
		else if tileDef.tileType is "clock"
			tile = new Clock tileDef
		else if tileDef.tileType is "config"
			tile = new ConfigTile tileDef, tileDef.configType
		else
			tile = new SceneButton tileDef
		tile.setTileIndex(@nextTileIdx++)
		return tile

	tileDefCleanCheck: (tileDef) ->
		tileDef.parentTag = @tilesSelector
		if "tileColour" not of tileDef
			tileDef.tileColour = @tileColours.getNextColour()
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
			@columnsDef = if @pageDef.columns? then @pageDef.columns.portrait else {}
			@tilesAcross = 3
			@tilesDown = 8
			@columnsAcross = 2
		else
			@columnsDef = if @pageDef.columns? then @pageDef.columns.landscape else {}
			@tilesAcross = 5
			@tilesDown = 5
			@columnsAcross = 3
		@noTitles = true
		if @columnsDef?
			@tilesAcross = 0
			for colDef, colIdx in @columnsDef
				if colDef.title? and colDef.title isnt ""
					@noTitles = false
				colType = if colDef.colType? then colDef.colType else ""
				if colType not of @columnTypes
					@columnTypes[colType] = { frontTileCount: 0, endTileCount: 0, colStartIdx: colIdx }
				@tilesAcross += colDef.colSpan
			@columnsAcross = @columnsDef.length
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
			cellXIdx += if @columnsDef? then @columnsDef[i].colSpan
		return xStart + cellXIdx * @cellWidth

	getTileSize: (tile) ->
		[@tileWidth * tile.tileDef.colSpan + (@tileSepXPixels * (tile.tileDef.colSpan-1)), @tileHeight * tile.tileDef.rowSpan + (@tileSepYPixels * (tile.tileDef.rowSpan-1))]

	calcFontSizePercent: ->
		100 * Math.max(@cellWidth, @cellHeight) / 300

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
		# Check for special positioning cues
		if tile.tileDef.positionCue is "end"
			colIdx = colInfo.colStartIdx + @columnsAcross - 2 - colInfo.endTileCount
			rowIdx = @tilesDown - tile.tileDef.rowSpan
			colInfo.endTileCount++
		else
			colIdx = colInfo.colStartIdx + Math.floor(colInfo.frontTileCount / @tilesDown)
			rowIdx = Math.floor(colInfo.frontTileCount % @tilesDown)
			colInfo.frontTileCount++
		# Column position
		cellX = @getColXPos(colIdx)
		cellY = @pageBorders[0] + (if @noTitles then 0 else @titlesTopMargin) + rowIdx * @cellHeight
		fontScaling = @calcFontSizePercent()
		return [cellX, cellY, fontScaling]

	reDoLayout: ->
		return @calcLayout()

	getTilesAcrossScreen: ->
		return @tilesAcross

	setTitlePositionCss: (colIdx, posX, posY, fontScaling) ->
		$('.' + @colTitleClass + "_" + colIdx).css {
			"margin-left": posX + "px", 
			"margin-top": posY + "px",
			"font-size": fontScaling + "%",
			"display": "block",
			"position": "absolute"
			}
		return
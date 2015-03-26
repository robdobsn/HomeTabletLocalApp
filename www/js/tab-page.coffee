class TabPage
	constructor: (@parentTag, @pageDef, @defaultActionFn, @mediaPlayHelper) ->
		@tileColours = new TileColours
		@tiles = []
		@titlesTopMargin = 60
		@titlesYPos = 10
		@pageBorders = [ 12, 12, 12, 12 ]
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
				if col.title? and col.title isnt ""
					$(@pageTitleSelector).append """
						<div class="#{@colTitleClass} #{@colTitleClass}_#{colIdx}">#{col.title}
						</div>
						"""
				colXPos = @getColXPos(colIdx)
				@setTitlePositionCss(colIdx, colXPos, @titlesYPos, 100)
		# Tiles
		@tileLayoutCount = 0
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
		tileBasics = @tileBasicsFromDef(tileDef)
		if tileBasics is null then return
		if tileDef.tileType is "calendar"
			tile = new CalendarTile tileBasics, @calendarUrl, tileDef.calDayIndex
		else if tileDef.tileType is "clock"
			tile = new Clock tileBasics
		else if tileDef.tileType is "config"
			tile = new ConfigTile tileBasics, tileDef.configType
		else
			tile = new SceneButton tileBasics
		tile.setTileIndex(@nextTileIdx++)
		return tile

	tileBasicsFromDef: (tileDef) ->
		tileColour = @tileColours.getNextColour()
		clickFn = @defaultActionFn
		if "clickFn" of tileDef
			clickFn = tileDef.clickFn
		colSpan = if tileDef.colSpan? then tileDef.colSpan else 1
		rowSpan = if tileDef.rowSpan? then tileDef.rowSpan else 1
		uri = if tileDef.uri? then tileDef.uri else ""
		vis = if tileDef.visibility? then tileDef.visibility else "both"
		name = if tileDef.name? then tileDef.name else tileDef.tileName
		tileText = if tileDef.tileText? then tileDef.tileText else name
		iconName = if tileDef.iconName? then tileDef.iconName else ""
		positionCue = if tileDef.positionCue? then tileDef.positionCue else ""
		isFavourite = false
		tileBasics = new TileBasics tileColour, colSpan, rowSpan, clickFn, uri, name, tileText, vis, @tilesSelector, tileDef.tileType, iconName, isFavourite, positionCue, @mediaPlayHelper
		tileBasics.setTierGroupIds(0,0)
		return tileBasics

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
			@columnsDef = @pageDef.columnsPortrait
			@tilesAcross = 3
			@tilesDown = 8
			@columnsAcross = 2
		else
			@columnsDef = @pageDef.columnsLandscape
			@tilesAcross = 5
			@tilesDown = 5
			@columnsAcross = 3
		@noTitles = true
		if @columnsDef?
			@tilesAcross = 0
			for colDef in @columnsDef
				@tilesAcross += colDef.colSpan
				if colDef.title? and colDef.title isnt ""
					@noTitles = false
			@columnsAcross = @columnsDef.length
		@cellWidth = (winWidth - @pageBorders[1] - @pageBorders[3] - (@groupSepPixels * Math.floor((@tilesAcross - 1) / 3))) / @tilesAcross
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
		[@tileWidth * tile.tileBasics.colSpan + (@tileSepXPixels * (tile.tileBasics.colSpan-1)), @tileHeight * tile.tileBasics.rowSpan + (@tileSepYPixels * (tile.tileBasics.rowSpan-1))]

	calcFontSizePercent: ->
		100 * Math.max(@cellWidth, @cellHeight) / 300

	getTitlePos: () ->
		return [0, 10, "200%"]

	getGroupTitleWidth: () ->
		return 400

	getCellPos: (tile) ->
		# Normal flow
		colIdx = Math.floor(@tileLayoutCount / @tilesDown)
		rowIdx = Math.floor(@tileLayoutCount % @tilesDown)
		# Check for special positioning cues
		if tile.tileBasics.positionCue is "end"
			rowIdx = @tilesDown - tile.tileBasics.rowSpan
			colIdx = @columnsAcross - 2
		else
			@tileLayoutCount++
		# Column position
		cellX = @getColXPos(colIdx)
		cellY = @pageBorders[0] + (if @noTitles then 0 else @titlesTopMargin) + rowIdx * @cellHeight
		fontScaling = @calcFontSizePercent()
		return [cellX, cellY, fontScaling]

	reDoLayout: ->
		isPortrait = @calcLayout()

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

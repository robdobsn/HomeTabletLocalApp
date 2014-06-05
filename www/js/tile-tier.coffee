class TileTier
	constructor: (@parentTag, @tierName) ->
		@groups = []
		@groupCols = []
		@groupSepPixels = 20
		@groupTitlesTopMargin = 60
		@tileSepXPixels = 20
		@tileSepYPixels = 20
		@nextTileIdx = 0
		@tierId = "sqTier" + @tierName
		@groupTitlesClass = "sqGroupTitles"
		@groupTitlesTagLocator = "#" + @tierId + " ." + @groupTitlesClass
		@groupsClass = "sqGroups"
		@groupsTagLocator = "#" + @tierId + " ." + @groupsClass

	getTileTierSelector: ->
		@groupsTagLocator + " .sqTileContainer"

	addToDom: ->
		# Add to html in parent tag
		$(@parentTag).append """
            <div id="#{@tierId}" class="sqTier">
                <div class="#{@groupTitlesClass}"/>
                <div class="#{@groupsClass}">
			        <div class="sqTileContainer" style="width:3000px;display:block;zoom:1;">
			        </div>
			    </div>
            </div>
			"""
			
	removeAll: ->
		@clearTiles()
		$("##{@tierId}").remove()

	clearTiles: ->
		# Container of tile groups
		for group in @groups
			group.clearTiles()

	clearTileGroup: (groupIdx) ->
		if groupIdx >= @groups.length then return
		@groups[groupIdx].clearTiles()

	addGroup: (groupTitle) ->
		groupIdx = @groups.length
		newTileGroup = new TileGroup this, @groupTitlesTagLocator, groupIdx, groupTitle
		@groups.push newTileGroup
		return groupIdx

	findGroupIdx: (groupName) ->
		groupIdx = 0
		for group in @groups
			if group.groupTitle is groupName
				return groupIdx
			groupIdx += 1
		return -1

	getTierHeight: ->
		tierSel = $("##{@tierId}")
		return tierSel[0].clientHeight

	getTierTop: ->
		tierSel = $("##{@tierId}")
		return tierSel[0].offsetTop

	calcLayout: ->
		winWidth = $(window).width()
		winHeight = $(window).height()
		isPortrait = (winWidth < winHeight)
		@tilesAcross = if isPortrait then 3 else 5
		@tilesDown = if isPortrait then 5 else 3
		@cellWidth = (winWidth - (@groupSepPixels * Math.floor((@tilesAcross - 1) / 3))) / @tilesAcross
		@cellHeight = (winHeight - @groupTitlesTopMargin) / @tilesDown
		@tileWidth = @cellWidth - @tileSepXPixels
		@tileHeight = @cellHeight - @tileSepYPixels
		@groupCols = []
		for group in @groups
			@groupCols.push group.getColsInGroup(@tilesDown, isPortrait)
		$("##{@tierId}").css {
			"height": document.documentElement.clientHeight + "px"
			}
		return isPortrait

	getTileSize: (colSpan, rowSpan) ->
		[@tileWidth * colSpan + (@tileSepXPixels * (colSpan-1)), @tileHeight * rowSpan + (@tileSepYPixels * (rowSpan-1))]

	getGroupStartX: (groupIdx) ->
		gIdx = 0
		xStart = 0
		while gIdx < groupIdx
			xStart += @groupCols[gIdx] * @cellWidth
			gIdx += 1
		xStart += groupIdx * @groupSepPixels
		return xStart

	getGroupStartXPositions: ->
		startPosns = []
		for group, groupIdx in @groups
			startPosns.push(getGroupStartX(groupIdx))

	calcFontSizePercent: ->
		100 * Math.max(@cellWidth, @cellHeight) / 300

	getGroupTitlePos: (groupIdx) ->
		xStart = @getGroupStartX(groupIdx)
		return [xStart, 10, "200%"]

	getCellPos: (groupIdx, colIdx, rowIdx) ->
		xStart = @getGroupStartX(groupIdx)
		colInGroup = colIdx
		cellX = xStart + colInGroup * @cellWidth
		cellY = @groupTitlesTopMargin + rowIdx * @cellHeight
		fontScaling = @calcFontSizePercent()
		return [cellX, cellY, fontScaling]

	getNextTileIdx: ->
		@nextTileIdx += 1
		return @nextTileIdx

	addTileToGroup: (groupIdx, tile) ->
		@groups[groupIdx].addExistingTile tile 

	reDoLayout: ->
		isPortrait = @calcLayout()
		for group in @groups
			group.repositionTiles(isPortrait)

	findExistingTile: (tileName) ->
		existingTile = null
		for group in @groups
			existingTile = group.findExistingTile(tileName)
			if existingTile	isnt null
				break
		return existingTile

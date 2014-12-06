class TileTier
	constructor: (@parentTag, @tierName) ->
		@groups = []
		@groupCols = []
		@groupSepPixels = 0
		@groupTitlesTopMargin = 60
		@tileSepXPixels = 20
		@tileSepYPixels = 20
		@nextTileIdx = 0
		@tierId = "sqTier" + @tierName
		@groupTitlesClass = "sqGroupTitles"
		@groupTitlesTagLocator = "#" + @tierId + " ." + @groupTitlesClass
		@groupsClass = "sqGroups"
		@groupsTagLocator = "#" + @tierId + " ." + @groupsClass
		@tilesAcross = 5 # Overridden in redolayout

	getTileTierSelector: ->
		@groupsTagLocator + " .sqTileContainer"

	addToDom: ->
		# Add to html in parent tag
		$(@parentTag).append """
            <div id="#{@tierId}" class="sqTier">
                <div class="#{@groupTitlesClass} snap"/>
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

	addGroup: (groupTitle, groupPriority) ->
		groupId = @groups.length
		newTileGroup = new TileGroup this, @groupTitlesTagLocator, groupId, groupTitle, groupPriority
		insertIdx = 0
		for gpidx in [@groups.length-1..0] by -1
			if @groups[gpidx].groupPriority >= groupPriority
				insertIdx = gpidx+1
				break
		@groups.splice(insertIdx,0,newTileGroup)
		return insertIdx

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
		while gIdx < groupIdx and gIdx < @groupCols.length
			xStart += @groupCols[gIdx] * @cellWidth
			gIdx += 1
		xStart += groupIdx * @groupSepPixels
		return xStart

	getGroupColXPositions: ->
		groupColXPosns = []
		for group, groupIdx in @groups
			colXPosns = []
			for colIdx in [0..@groupCols[groupIdx]-1]
				cellPos = @getCellPos(groupIdx, colIdx, 0)
				colXPosns.push(cellPos[0])
			groupColXPosns.push(colXPosns)
		return groupColXPosns

	calcFontSizePercent: ->
		100 * Math.max(@cellWidth, @cellHeight) / 300

	getGroupTitlePos: (groupIdx) ->
		xStart = @getGroupStartX(groupIdx)
		return [xStart, 10, "200%"]

	getGroupTitleWidth: (groupIdx) ->
		xStart = @getGroupStartX(groupIdx)
		xEnd = @getGroupStartX(groupIdx+1)
		return xEnd - xStart - @groupSepPixels

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
		for group, groupIdx in @groups
			group.repositionTiles(isPortrait, groupIdx)

	findExistingTile: (tileName, groupName) ->
		existingTile = null
		for group in @groups
			if groupName? and groupName isnt null
				if group.groupTitle isnt groupName
					continue
			existingTile = group.findExistingTile(tileName)
			if existingTile	isnt null
				break
		return existingTile

	getTilesAcrossScreen: ->
		return @tilesAcross
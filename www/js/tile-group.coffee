class TileGroup
	constructor: (@tileTier, @groupTitlesTag, @groupIdx, @groupTitle) ->
		@tiles = []
		@tilePositions = []
		@groupIdTag = "sqGroupTitle" + groupIdx
		$(groupTitlesTag).append """
	        <div class="sqGroupTitle #{@groupIdTag}">#{@groupTitle}
	        </div>
			"""

	clearTiles: ->
		for tile in @tiles
			tile.removeFromDoc()
		@tiles = []

	numTiles: ->
		return @tiles.length

	findBestPlaceForTile: (colSpan, rowSpan, tilesDown, tilesAcross) ->
		# Algorithm to find best location for a tile
		# Exhaustive search for a gap large enough
		bestColIdx = 0
		bestRowIdx = 0
		# This time work across - filling each row before moving down
		for rowIdx in [0..tilesDown-1]
			for colIdx in [0..tilesAcross-1]
				# Check if the tile will fit in the remaining columns
				if ((colIdx + colSpan) > tilesAcross) then continue
				posValid = true
				for tilePos in @tilePositions
					if tilePos.intersects (new TilePosition(true, colIdx, rowIdx, colSpan, rowSpan))
						posValid = false
						break
				if posValid 
					bestColIdx = colIdx
					bestRowIdx = rowIdx
					break
			if posValid then break
		if not posValid then return new TilePosition false
		new TilePosition true, bestColIdx, bestRowIdx, colSpan, rowSpan

	getColsInGroup: (tilesDown, isPortrait) ->
		# Simple algorithm to find the number of columns in a tile-group
		# May get it wrong if there are many wider tiles and not enough single
		# tiles to fill the gaps
		@tiles.sort(@sortByTileWidth)
		@tilePositions = []
		cellCount = 0
		maxColSpan = 1
		for tile in @tiles
			if tile.isVisible(isPortrait)
				cellCount += tile.tileBasics.colSpan * tile.tileBasics.rowSpan
				maxColSpan = Math.max(maxColSpan, tile.tileBasics.colSpan)
		estColCount = Math.floor((cellCount + tilesDown - 1) / tilesDown)
		estColCount = Math.max(estColCount, maxColSpan)
		for tile, tileIdx in @tiles
			if tile.isVisible(isPortrait)
				@tilePositions.push @findBestPlaceForTile(tile.tileBasics.colSpan, tile.tileBasics.rowSpan, tilesDown, estColCount)
			else
				@tilePositions.push new TilePosition false
		return estColCount

	# addTile: (tileColour, colSpan) ->
	# 	tile = new Tile tileColour, colSpan
	# 	tile.setTileIndex(@tileTier.getNextTileIdx())
	# 	tile.addToDoc()
	# 	@tiles.push tile

	addExistingTile: (tile) ->
		tile.setTileIndex(@tileTier.getNextTileIdx())
		tile.addToDoc()
		@tiles.push tile

	sortByTileWidth: (a, b) ->
		if a.tileBasics.colSpan is b.tileBasics.colSpan
			return a.tileIdx - b.tileIdx
		return a.tileBasics.colSpan - b.tileBasics.colSpan

	repositionTiles: (isPortrait) ->
		[titleX, titleY, fontSize] = @tileTier.getGroupTitlePos(@groupIdx)
		$(@groupTitlesTag + " ."+@groupIdTag).css {
			"margin-left": titleX + "px", 
			"margin-top": titleY + "px",
			"font-size": fontSize,
			"width": @tileTier.getGroupTitleWidth(@groupIdx),
			"overflow": "hidden"
			}
		# Order tiles so widest are at the end
		for tile, tileIdx in @tiles
			if (@tilePositions[tileIdx].tileValid)
				[tileWidth, tileHeight] = @tileTier.getTileSize(tile.tileBasics.colSpan, tile.tileBasics.rowSpan)
				[xPos, yPos, fontScaling] = @tileTier.getCellPos(@groupIdx, @tilePositions[tileIdx].xPos, @tilePositions[tileIdx].yPos)
				tile.reposition xPos, yPos, tileWidth, tileHeight, fontScaling
				# console.log "Grp=" + @groupIdx + "Tile=" + tile.tileBasics.tileName + "(" + tileIdx + ") Pos " + xPos + " " + yPos
			else
				tile.setInvisible()
				# console.log "Grp=" + @groupIdx + "Tile=" + tile.tileBasics.tileName + "(" + tileIdx + ") Invisible " + tile.tileBasics.visibility + " orient=" + isPortrait

	findExistingTile: (tileName) ->
		existingTile = null
		for tile in @tiles
			if tile.tileBasics.tileName is tileName
				existingTile = tile
				break
		return existingTile

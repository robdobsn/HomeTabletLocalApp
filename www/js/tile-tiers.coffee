class TileTiers
	constructor: (@parentTag) ->
		@tiers = []

	addTier: (tier) ->
		@tiers.push tier

	getTileContainerSelector: (tierIdx) ->
		if tierIdx >= @tiers.length then return ""
		@tiers[tierIdx].getTileContainerSelector()

	addGroup: (tierIdx, groupTitle) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].addGroup groupTitle

	clearGroup: (tierIdx, groupIdx) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].clearTileGroup()

	reDoLayout: ->
		tier.reDoLayout() for tier in @tiers

	addTileToTierGroup: (tierIdx, groupIdx, tile) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].addTileToGroup groupIdx, tile

	clear: ->
		for tier in @tiers
			tier.clearTiles()
		
	findExistingTile: (tierIdx, tileName) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].findExistingTile tileName

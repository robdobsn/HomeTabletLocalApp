class TileTiers
	constructor: (@parentTag) ->
		@tiers = []

	addTier: (tier) ->
		@tiers.push tier

	addGroup: (tierIdx, groupTitle) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].addGroup groupTitle

	reDoLayout: ->
		tier.reDoLayout() for tier in @tiers

	addTileToTierGroup: (tierIdx, groupIdx, tile) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].addTileToGroup groupIdx, tile
		
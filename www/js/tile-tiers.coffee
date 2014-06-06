class TileTiers
	constructor: (@parentTag) ->
		@tiers = []

	numTiers: ->
		return @tiers.length

	getTier: (tierIdx) ->
		return @tiers[tierIdx]
		
	addTier: (tier) ->
		@tiers.push tier
		return @tiers.length - 1

	removeAll: () ->
		@clear()
		@tiers = []

	findTierIdx: (tierName) ->
		tierIdx = 0
		for tier in @tiers
			if tier.tierName is tierName
				return tierIdx
			tierIdx += 1
		return -1

	getTierTop: (tierName) ->
		tierIdx = @findTierIdx(tierName)
		if tierIdx < 0 then return -1
		return @tiers[tierIdx].getTierTop()

	getTileTierSelector: (tierName) ->
		for tier in @tiers
			if tier.tierName is tierName
				return tier.getTileTierSelector()
		return ""

	getTierName: (tierIdx) ->
		if tierIdx >= @tiers.length then return ""
		@tiers[tierIdx].tierName

	addGroup: (tierIdx, groupTitle) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].addGroup groupTitle

	clearGroup: (tierIdx, groupIdx) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].clearTileGroup groupIdx

	findGroupIdx: (tierIdx, groupName) ->
		if tierIdx >= @tiers.length then return
		@tiers[tierIdx].findGroupIdx groupName

	reDoLayout: ->
		tier.reDoLayout() for tier in @tiers

	addTileToTierGroup: (tierIdx, groupIdx, tile) ->
		if tierIdx >= @tiers.length then return
		tile.tileBasics.setTierGroupIds(tierIdx, groupIdx)
		@tiers[tierIdx].addTileToGroup groupIdx, tile

	clear: ->
		for tier in @tiers
			tier.removeAll()
		
	findExistingTile: (tileName, groupName) ->
		for tier in @tiers
			exTile = tier.findExistingTile(tileName, groupName)
			if exTile isnt null then return exTile
		return null

	getGroupColXPositions: (tierIdx) ->
		if tierIdx >= @tiers.length then return
		return @tiers[tierIdx].getGroupColXPositions()

	getTilesAcrossScreen: ->
		if @tiers.length > 0
			return @tiers[0].getTilesAcrossScreen()
		return 5

class AppPages
	constructor: (@parentTag, @defaultActionFn, @mediaPlayHelper) ->
		@pages = {}
		@curPage = ""

	getPage: (pageName) ->
		return @pages[pageIdx]
		
	addPage: (page) ->
		@pages[page.pageName] = page
		return

	removeAll: () ->
		@clear()
		@pages = {}
		return

	clear: ->
		for page of @pages
			page.removeAll()
		return

	setCurrentPage: (pageName) ->
		@curPage = pageName

	build: (@tabletConfig, @automationActionGroups) ->
		# console.log JSON.stringify(tabletConfig.getConfigData())
		# console.log JSON.stringify(automationActionGroups)

		@tabletConfig = 
			pages: 
				"Home": 
					pageName: "Home"
					pageTitle: "Home"
					columnsLandscape: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					columnsPortrait: [ 
						{ "title": "", "colSpan": 2 },
						{ "title": "", "colSpan": 1, "colType": "nav" }
					]
					tiles: [
						{ "tileType": "clock", "tileName": "Clock", "groupName": "Clock", "positionCue": "end", "rowSpan": 2, "colSpan": 2 },
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
						{ "tileType": "action", "tileName": "Grace Off", "groupName": "Grace Bed", "url": "http://graceoff", "tileText": "Grace OFF", "rowSpan": 1, "colSpan": 2 }
					]

	display: ->
		if @curPage is "" then @curPage = "Home"
		if @curPage of @tabletConfig.pages
			newPage = new TabPage(@parentTag, @tabletConfig.pages[@curPage], @defaultActionFn)
			newPage.updateDom()

    # addTileToTierGroup: (tileDef, tile) ->
    #     tierName = tileDef.tierName
    #     groupName = tileDef.groupName
    #     groupPriority = if "groupPriority" of tileDef then tileDef.groupPriority else 5
    #     tierIdx = @tileTiers.findTierIdx(tierName)
    #     if tierIdx < 0 then tierIdx = @tileTiers.findTierIdx("actionsTier")
    #     if tierIdx < 0 then return
    #     if groupName is "" then groupName = "Lights"
    #     groupIdx = @getUIGroupIdxAddGroupIfReqd(tierIdx, groupName, groupPriority)
    #     #groupIdx = @tileTiers.findGroupIdx(tierIdx, groupName)
    #     #if groupIdx < 0 then return
    #     @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)
    #     return

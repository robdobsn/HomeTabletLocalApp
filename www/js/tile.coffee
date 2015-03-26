class Tile
	constructor: (@tileDef) ->
		@contentFontScaling = 1
		@iconHeight = 50
		@buttonTextX = 20
		return

	addToDoc: ->
		@tileId = "sqTile_" + @tileDef.tierIdx + "_" + @tileDef.groupIdx + "_" + @tileIdx
		$(@tileDef.parentTag).append """
			<a class="sqTile" id="#{@tileId}" 
					href="javascript:void(0);" 
					style="background-color:#{@tileDef.tileColour};
							display:block; opacity:1;">
			  <div class="sqInner">
			  </div>
			</a>
			"""
		if @tileDef.clickFn?
			$("##{@tileId}").click =>
				(@tileDef.clickFn) @tileDef
		@contents = $("##{@tileId}>.sqInner")
		return

	distMoved: (x1, y1, x2, y2) ->
		xSep = x1 - x2
		ySep = y1 - y2
		dist = Math.sqrt((xSep*xSep)+(ySep*ySep))
		return dist

	removeFromDoc: ->
		if @refreshId?
			clearInterval(@refreshId)
		$('#'+@tileId).remove()
		return

	setTileIndex: (@tileIdx) ->

	reposition: (@posX, @posY, @sizeX, @sizeY, @fontScaling) ->
		@setPositionCss('#'+@tileId, @posX, @posY, @sizeX, @sizeY, @fontScaling)
		iconSel = '#'+@tileId + " .sqSceneButtonIcon img"
		@setPositionCss(iconSel, 10, (@sizeY-@iconHeight)/2, null, @iconHeight)
		textSel = '#'+@tileId + " .sqSceneButtonText"
		txtHeight = $(textSel).height()
		@setPositionCss('#'+@tileId + " .sqSceneButtonText", @buttonTextX, (@sizeY-txtHeight)/2)
		return

	setPositionCss: (selector, posX, posY, sizeX, sizeY, fontScaling) ->
		css = {
			"margin-left": posX + "px", 
			"margin-top": posY + "px"
		}
		if sizeX? then css["width"] = sizeX + "px"
		if sizeY? then css["height"] = sizeY + "px"
		if fontScaling? then css["font-size"] = (fontScaling * @contentFontScaling) + "%"
		$(selector).css(css)
		return

	setContentFontScaling: (@contentFontScaling) ->
		@setPositionCss(@posX, @posY, @sizeX, @sizeY, @fontScaling)
		return

	getElement: (element) ->
		return $('#'+@tileId + " " + element)

	isVisible: (isPortrait) ->
		if @tileDef.visibility is "all" then return true
		if @tileDef.visibility is "portrait" and isPortrait then return true
		if @tileDef.visibility is "landscape" and (not isPortrait) then return true
		return false

	setInvisible: ->
		$('#'+@tileId).css {
			"display": "none"
			}
		return

	setRefreshInterval: (intervalInSecs, @callbackFn, firstCallNow) ->
		if firstCallNow
			@callbackFn()
		@refreshId = setInterval =>
			@callbackFn()
		, intervalInSecs * 1000
		return

	setIcon: (iconName) ->
		iconUrl = 'img/' + iconName + '.png'
		if iconUrl isnt ""
			$('#'+@tileId+" .sqSceneButtonIcon img").attr("src", iconUrl)
		return

	setText: (@textStr) ->
		$('#'+@tileId+" .sqSceneButtonText").html textStr
		return

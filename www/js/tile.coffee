class Tile
	constructor: (@tileBasics) ->
		@contentFontScaling = 1
		return

	addToDoc: ->
		@tileId = "sqTile_" + @tileBasics.tierIdx + "_" + @tileBasics.groupIdx + "_" + @tileIdx
		$(@tileBasics.parentTag).append """
			<a class="sqTile" id="#{@tileId}" 
					href="javascript:void(0);" 
					style="background-color:#{@tileBasics.bkColour};
							display:block; opacity:1;">
			  <div class="sqInner">
			  </div>
			</a>
			"""
		if @tileBasics.clickFn?
			$("##{@tileId}").click =>
				@playClickSound()
				(@tileBasics.clickFn) @tileBasics.clickParam
		@contents = $("##{@tileId}>.sqInner")
		return

	playClickSound: ->
		@tileBasics.mediaPlayHelper.play("click")
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
		@setPositionCss(@posX, @posY, @sizeX, @sizeY, @fontScaling)
		return

	setPositionCss: (posX, posY, sizeX, sizeY, fontScaling) ->
		$('#'+@tileId).css {
			"margin-left": posX + "px", 
			"margin-top": posY + "px",
			"width": sizeX + "px", 
			"height": sizeY + "px", 
			"font-size": (fontScaling * @contentFontScaling) + "%",
			"display": "block"
			}
		return

	setContentFontScaling: (@contentFontScaling) ->
		@setPositionCss(@posX, @posY, @sizeX, @sizeY, @fontScaling)
		return

	getElement: (element) ->
		return $('#'+@tileId + " " + element)

	isVisible: (isPortrait) ->
		if @tileBasics.visibility is "all" then return true
		if @tileBasics.visibility is "portrait" and isPortrait then return true
		if @tileBasics.visibility is "landscape" and (not isPortrait) then return true
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

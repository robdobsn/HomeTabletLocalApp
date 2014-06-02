class Tile
	constructor: (@tileBasics) ->
		@contentFontScaling = 1
		@pressStarted = 0

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
		@addClickHandling()
		@contents = $("##{@tileId}>.sqInner")
		if @tileBasics.isFavourite
			$("##{@tileId}").draggable({
		      cancel: "a.ui-icon"
		      revert: "invalid"
		      containment: "document"
		      helper: "clone"
		      cursor: "move"
		    })

	addClickHandling: ->
		longPressTime = 1500
		$("##{@tileId}").on "mousedown", (e) =>
			e.preventDefault()
			@pressStarted = new Date().getTime()
			@touchXPos = e.pageX
			@touchYPos = e.pageY
		$("##{@tileId}").on "touchstart", (e) =>
			e.preventDefault()
			@pressStarted = new Date().getTime()
			touchEvent = e.originalEvent.touches[0]
			@touchXPos = touchEvent.pageX
			@touchYPos = touchEvent.pageY
		$("##{@tileId}").on "mouseup touchend", =>
			if new Date().getTime() >= @pressStarted + longPressTime
				alert ("Long press")
			else
				@tileBasics.mediaPlayHelper.play("click")
				(@tileBasics.clickFn) @tileBasics.clickParam
			@pressStarted = 0

	removeFromDoc: ->
		if @refreshId?
			clearInterval(@refreshId)
		$('#'+@tileId).remove()

	setTileIndex: (@tileIdx) ->

	reposition: (@posX, @posY, @sizeX, @sizeY, @fontScaling) ->
		@setPositionCss(@posX, @posY, @sizeX, @sizeY, @fontScaling)

	setPositionCss: (posX, posY, sizeX, sizeY, fontScaling) ->
		$('#'+@tileId).css {
			"margin-left": posX + "px", 
			"margin-top": posY + "px",
			"width": sizeX + "px", 
			"height": sizeY + "px", 
			"font-size": (fontScaling * @contentFontScaling) + "%",
			"display": "block"
			}

	setContentFontScaling: (@contentFontScaling) ->
		@setPositionCss(@posX, @posY, @sizeX, @sizeY, @fontScaling)

	getElement: (element) ->
		$('#'+@tileId + " " + element)

	isVisible: (isPortrait) ->
		if @tileBasics.visibility is "all" then return true
		if @tileBasics.visibility is "portrait" and isPortrait then return true
		if @tileBasics.visibility is "landscape" and (not isPortrait) then return true
		return false

	setInvisible: ->
		$('#'+@tileId).css {
			"display": "none"
			}		

	setRefreshInterval: (intervalInSecs, @callbackFn, firstCallNow) ->
		if firstCallNow
			@callbackFn()
		@refreshId = setInterval =>
			@callbackFn()
		, intervalInSecs * 1000

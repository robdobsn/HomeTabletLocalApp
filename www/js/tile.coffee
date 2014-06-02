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
		# A hack here - only tier 0 is draggable!
		if @tileBasics.tierIdx is 0
			$("##{@tileId}").draggable({
		      cancel: "a.ui-icon"
		      revert: "invalid"
		      containment: "document"
		      helper: "clone"
		      cursor: "move"
		    })

	addClickHandling: ->
		longPressTime = 1500
		dragDistMovedTest = 20
		$("##{@tileId}").on "mousedown", (e) =>
			e.preventDefault()
			@pressStarted = new Date().getTime()
			@startDragXPos = e.pageX
			@startDragYPos = e.pageY
			console.log("mousedown " + @startDragXPos + " " + @startDragYPos)
		$("##{@tileId}").on "touchstart", (e) =>
			e.preventDefault()
			@pressStarted = new Date().getTime()
			touchEvent = e.originalEvent.touches[0]
			@startDragXPos = touchEvent.pageX
			@startDragYPos = touchEvent.pageY
			console.log("touchdown " + @startDragXPos + " " + @startDragYPos)
		$("##{@tileId}").on "mouseleave", =>
			@pressStarted = 0
		$("##{@tileId}").on "mousemove", (e) =>
			if @pressStarted is 0 then return
			curX = e.pageX
			curY = e.pageY
			distMoved = @distMoved(curX, curY)
			if distMoved > dragDistMovedTest
				$(this).trigger(e)
			console.log("mousemove " + curX + " " + curY + " " + distMoved)
		$("##{@tileId}").on "touchmove", (e) =>
			if @pressStarted is 0 then return
			e.preventDefault()
			@pressStarted = new Date().getTime()
			touchEvent = e.originalEvent.touches[0]
			curX = touchEvent.pageX
			curY = touchEvent.psageY
			distMoved = @distMoved(curX, curY)
			if distMoved > dragDistMovedTest
				$(this).trigger(e)
			console.log("mousemove " + curX + " " + curY + " " + distMoved)
		$("##{@tileId}").on "mouseup touchend", =>
#			if new Date().getTime() >= @pressStarted + longPressTime
#				alert ("Long press")
#			else
#				@playClickSound()
#				(@tileBasics.clickFn) @tileBasics.clickParam
			@pressStarted = 0

	distMoved: (x,y) ->
		xSep = @startDragXPos - x
		ySep = @startDragYPos - y
		dist = Math.sqrt(xSep*xSep+ySep*ySep)

#		if @tileBasics.clickFn?
#			$("##{@tileId}").click =>
#				@playClickSound()
#				(@tileBasics.clickFn) @tileBasics.clickParam

	playClickSound: ->
		window.soundClick.play() if window.soundClick?

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

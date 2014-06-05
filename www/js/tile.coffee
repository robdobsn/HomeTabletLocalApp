class Tile
	constructor: (@tileBasics) ->
		@contentFontScaling = 1
		@pressStarted = 0
		@scrollPending = false
		@touchState = 0
		@lastTouchTime = 0

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
		# if @tileBasics.isFavourite
		# 	$("##{@tileId}").draggable({
		#       cancel: "a.ui-icon"
		#       revert: "invalid"
		#       containment: "document"
		#       helper: "clone"
		#       cursor: "move"
		#     })

	distMoved: (x1, y1, x2, y2) ->
		xSep = x1 - x2
		ySep = y1 - y2
		dist = Math.sqrt((xSep*xSep)+(ySep*ySep))
		return dist

	addClickHandling: ->
		longPressTime = 1500
		maxDistMovedForClick = 20
		minMsBetweenTouches = 100
		# $("##{@tileId}").on "mousedown", (e) =>
		# 	e.preventDefault()
		# 	@pressStarted = new Date().getTime()
		# 	@mouseStX = e.pageX
		# 	@mouseStY = e.pageY
		# $("##{@tileId}").on "mouseup", (e) =>
		# 	e.preventDefault()
		# 	xPos = e.pageX
		# 	yPos = e.pageY
		# 	dist = @distMoved(@mouseStX, @mouseStY, xPos,yPos)
		# 	if dist > maxDistMovedForClick
		# 		console.log("distMoved too far for click = " + dist)
		# 		return
		# 	console.log("distMoved ok = " + dist)
		# 	if new Date().getTime() >= @pressStarted + longPressTime
		# 		alert ("Long press")
		# 	else
		# 		@tileBasics.mediaPlayHelper.play("click")
		# 		(@tileBasics.clickFn) @tileBasics.clickParam
		# 	@pressStarted = 0
		$("##{@tileId}").on "touchstart", (e) =>
			# This enables scrolling when touching other parts of the
			# screen not covered by buttons
			e.preventDefault()
			timeNow = new Date().getTime()
			console.log("TimeNow " + timeNow + " LTT " + @lastTouchTime + " MinMS " + minMsBetweenTouches)
			if @touchState is 0 and @lastTouchTime + minMsBetweenTouches < timeNow
				touchEvent = e.originalEvent.touches[0]
				@touchStX = touchEvent.pageX
				@touchStY = touchEvent.pageY
				@scrollStX = document.body.scrollLeft
				@scrollStY = document.body.scrollTop
				@lastTouchTime = timeNow
				@touchState = 1
		$("##{@tileId}").on "touchmove", (e) =>
			e.preventDefault()
			touchEvent = e.originalEvent.touches[0]
			@touchCurX = touchEvent.pageX
			@touchCurY = touchEvent.pageY
			if @touchState is 1
				if @distMoved(@touchStX, @touchStY, @touchCurX, @touchCurY) > maxDistMovedForClick
					@touchState = 2
			if @touchState is 2
				aaaaa = 1
		$("##{@tileId}").on "touchend", (e) =>
			e.preventDefault()
			console.log("Touchend")
			console.log("touchend " + @touchState + ", SS " + @scrollStX + "," + @scrollStY + " ST " + @touchStX + "," + @touchStY + " SC " + @touchCurX + "," + @touchCurY)
			if @touchState isnt 0
				@touchState = 0
		# $("##{@tileId}").on "touchstart", (e) =>
		# 	e.preventDefault()
		# 	@pressStarted = new Date().getTime()
		# 	touchEvent = e.originalEvent.touches[0]
		# 	@touchXPos = touchEvent.pageX
		# 	@touchYPos = touchEvent.pageY
		# 	@touchCurX = @touchXPos
		# 	@touchCurY = @touchYPos
		#	console.log("touch start " + @touchXPos + "," + @touchYPos)
		# $("##{@tileId}").on "touchmove", (e) =>
		# 	# This is captured because touchend event on android doesn't
		# 	# contain the touches element
		# 	e.preventDefault()
		# 	touchEvent = e.originalEvent.touches[0]
		# 	@touchCurX = touchEvent.pageX
		# 	@touchCurY = touchEvent.pageY
		# $("##{@tileId}").on "touchend", (e) =>
		# 	e.preventDefault()
		# 	@scrollPending = false
		# 	console.log("touch end " + @touchCurX + "," + @touchCurY)
		# 	dist = @distMoved(@touchCurX,@touchCurY)
		# 	if dist > maxDistMovedForClick
		# 		console.log("touch distMoved too far for click = " + dist)
		# 		@doScroll(@touchXPos, @touchYPos, @touchCurX, @touchCurY)
		# 		return
		# 	console.log("touch distMoved ok = " + dist)
		# 	if new Date().getTime() >= @pressStarted + longPressTime
		# 		alert ("Long press")
		# 	else
		# 		@tileBasics.mediaPlayHelper.play("click")
		# 		(@tileBasics.clickFn) @tileBasics.clickParam
		# 	@pressStarted = 0

	doScroll: (x1, y1, x2, y2) ->
		console.log("doScroll " + x1 + ", " + y1 + " : " + x2 + ", " + y2)
		#window.scrollBy(0,0)

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

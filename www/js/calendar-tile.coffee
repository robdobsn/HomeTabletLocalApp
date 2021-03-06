class App.CalendarTile extends App.Tile
	constructor: (@app, tileDef, @calDayIndex) ->
		super tileDef
		@shortDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		@calLineCount = 0; @calCharCount = 0; @calMaxLineLen = 0
		@secsBetweenCalendarRefreshes = 60
		return

	handleAction: (action) ->
		if action is "next"
			if @calDayIndex < @app.calendarManager.getCalNumDays()
				@calDayIndex++
		else if action is "prev"
			if @calDayIndex > 0
				@calDayIndex--
		@updateCalendar()
		return

	addToDoc: () ->
		super()
		@setRefreshInterval(@secsBetweenCalendarRefreshes, @updateCalendar, true)
		return

	updateCalendar: () ->
		calData = @app.calendarManager.getCalData()
		@showCalendar(calData)

	showCalendar: (jsonData) ->
		if not ("calEvents" of jsonData)
			return
		newHtml = ""

		# Calendar boxes can be for each of the next few days so see which date this one is for
		reqDate = new Date()
		reqDate.setDate(reqDate.getDate()+@calDayIndex);
		reqDateStr = @toZeroPadStr(reqDate.getFullYear(), 4) + 
				@toZeroPadStr(reqDate.getMonth()+1, 2) +
				@toZeroPadStr(reqDate.getDate(), 2)
		calTitle = ""
		if @calDayIndex is 0
			calTitle = "Today "
		calTitle += @shortDayNames[reqDate.getDay()]
		calTitle += " " + @toZeroPadStr(reqDate.getDate(), 2) + "/" +
			@toZeroPadStr(reqDate.getMonth()+1, 2) + "/" +
			@toZeroPadStr(reqDate.getFullYear(), 4)

		# Format the text to go into the calendar and keep stats on it for font sizing
		@calLineCount = 0; @calCharCount = 0; @calMaxLineLen = 0
		for event in jsonData["calEvents"]
			if event["eventDate"] is reqDateStr
				@calLineCount += 1
				newLine = """
					<span class="sqCalEventStart">#{event["eventTime"]}</span>
					<span class="sqCalEventDur"> (#{@formatDurationStr(event["duration"])}) </span>
					<span class="sqCalEventSummary">#{event["summary"]}</span>
					"""
				newHtml += """
					<li class="sqCalEvent">
						#{newLine}
					</li>
					"""
				@calCharCount += newLine.length
				@calMaxLineLen = if @calMaxLineLen < newLine.length then newLine.length else @calMaxLineLen

		# Check for non-busy day
		if newHtml is ""
			newHtml = "Nothing doing"
		# Place the calendar text
		@contents.html """
			<div class="sqCalTitle" style="font-size:26px;font-weight:bold;color:white;">#{calTitle}</div>
			<ul class="sqCalEvents">
				#{newHtml}
			</ul>
			"""
		# Calculate optimal font size
		@recalculateFontScaling()
		return

	# Utility function for leading zeroes
	toZeroPadStr: (value, digits) ->
		s = "0000" + value
		return s.substr(s.length-digits)

	# Override reposition to handle font scaling
	reposition: (posX, posY, sizeX, sizeY) ->
		super(posX, posY, sizeX, sizeY)
		@recalculateFontScaling()
		return

	# Calculate width of text from DOM element or string. By Phil Freo <http://philfreo.com>
	# This works but doesn't do what I want - which is to calculate the actual width of text
	# including overflowed text in a box of fixed width - what it does is removes the box width
	# restriction and calculates the overall width of the text at the given font size - useful
	# in some situations but not what I need
	calcTextWidth: (text, fontSize, boxWidth) ->
		@fakeEl = $("<span>").hide().appendTo(document.body) unless @fakeEl?
		@fakeEl.text(text).css("font-size", fontSize)
		return @fakeEl.width()

	findOptimumFontSize: (optHeight, docElem, initScale, maxFontScale) ->
		availSize = (if optHeight then @sizeY else @sizeX) * 0.9
		calText = @getElement(docElem)
		# console.log @calcTextWidth(calText.text(), calText.css("font-size"))
		textSize = if optHeight then calText.height() else @calcTextWidth(calText.text(), calText.css("font-size"))
		if not textSize? then return 1.0
		fontScale = if optHeight then availSize / textSize else initScale
		fontScale = if fontScale > maxFontScale then maxFontScale else fontScale
		@setContentFontScaling(fontScale)
		sizeInc = 1.0
		# Iterate through possible sizes in a kind of binary tree search
		for i in [0..6]
			calText = @getElement(docElem)
			textSize = if optHeight then calText.height() else @calcTextWidth(calText.text(), calText.css("font-size"))
			if not textSize? then return fontScale
			if textSize > availSize
				fontScale = fontScale * (1 - (sizeInc/2))
				@setContentFontScaling(fontScale)
			else if textSize < (availSize * 0.75) and fontScale < maxFontScale
				fontScale = fontScale * (1 + sizeInc)
				@setContentFontScaling(fontScale)
			else
				break
			sizeInc *= 0.5
		return fontScale

	# Provide a different font scaling based on the amount of text in the calendar box
	recalculateFontScaling: () ->
		if not @sizeX? or not @sizeY? or (@calLineCount is 0) then return
		fontScale = @findOptimumFontSize(true, ".sqCalEvents", 1.0, 2.2)
		#fontScale = @findOptimumFontSize(false, ".sqCalEvents", yScale)
		@setContentFontScaling(fontScale)
		return
	
	setContentFontScaling: (contentFontScaling) ->
		css =
			"font-size": (100 * contentFontScaling) + "%"
		$(".sqCalEvents").css(css)
		return

	formatDurationStr: (val) ->
		dur = val.split(":")
		days = parseInt(dur[0])
		hrs = parseInt(dur[1])
		mins = parseInt(dur[2])
		outStr = ""
		if days is 0 and hrs isnt 0 and mins is 30
			outStr = (hrs+0.5) + "h"
		else
			outStr = if days is 0 then "" else (days + "d")
			outStr += if hrs is 0 then "" else (hrs + "h")
			outStr += if mins is 0 then "" else (mins + "m")
		return outStr


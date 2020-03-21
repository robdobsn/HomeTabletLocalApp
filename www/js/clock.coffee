class App.Clock extends App.Tile
	constructor: (tileDef) ->
		super tileDef
		@dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		@shortDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		@monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
		@shortMonthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
		return

	addToDoc: () ->
		super()
		@contents.append """
			<div class="sqClockDow" style="text-align:center"></div>
			<div class="sqClockDayMonthYear" style="text-align:center"></div>
			<div class="sqClockTime" style="display:block;text-align:center">
				<span class="sqClockHours" style="padding:5px"></span>
				<span class="sqClockMins"></span>
				<span class="sqClockSecs" style="display:inline;font-size:20%;position:absolute;"></span>
			</div>
			<span class="sqClockPoint1" 
					style="position:absolute;
					       -moz-animation: mymove 1s ease infinite;
					       -webkit-animation: mymove 1s ease infinite;">:
			</span> 
			"""
		@updateClock()
		@setRefreshInterval(1, @updateClock, false)
		return

	reposition: (@posX, @posY, @sizeX, @sizeY) ->
		super(@posX, @posY, @sizeX, @sizeY)
		timePos = (@sizeY / 3)
		$('#'+@tileId+" .sqClockDayMonthYear").css
			position: "absolute"
			fontSize: (@sizeY/6) + "px"
			top: (@sizeY / 10) + "px"
			width: "100%"
		$('#'+@tileId+" .sqClockTime").css
			position: "absolute"
			fontSize: (@sizeY/2) + "px"	
			top: timePos + "px"
			left: "-7px"
			width: "100%"
		timeTextHeight = $('#'+@tileId+" .sqClockTime").height()
		$('#'+@tileId+" .sqClockPoint1").css
			position: "absolute"
			left: (@sizeX/2-12) + "px"
			top: (timePos + (timeTextHeight/5)) + "px"
			fontSize: (@sizeY/3.5) + "px"				
		return

	updateClock: () ->
		dt = new Date()
		$('#'+@tileId+" .sqClockDayMonthYear").html @shortDayNames[dt.getDay()] + " " + dt.getDate() + " " + @shortMonthNames[dt.getMonth()] + " " + dt.getFullYear()
		$('#'+@tileId+" .sqClockHours").html (if dt.getHours() < 10 then "0" else "") + dt.getHours()
		$('#'+@tileId+" .sqClockMins").html (if dt.getMinutes() < 10 then "0" else "") + dt.getMinutes()
		# $('#'+@tileId+" .sqClockSecs").html (if dt.getSeconds() < 10 then "0" else "") + dt.getSeconds()
		return

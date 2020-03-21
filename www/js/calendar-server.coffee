class App.CalendarManager
	constructor: (@app) ->
		@calendarData = []
		@secsBetweenCalendarRefreshes = 60
		@firstRefreshAfterFailSecs = 10
		@nextRefreshesAfterFailSecs = 60
		@numRefreshFailuresSinceSuccess = 0
		@calendarUrl = ""
		@calendarNumDays = 31
		return

	setConfig: (config) ->
		if config.url?
			@calendarUrl = config.url
		if config.numDays?
			@calendarNumDays = config.numDays
		@requestCalUpdate()
		return

	requestCalUpdate: ->
		if @calendarUrl is "" 
			return
		dateTimeNow = new Date()
		console.log("calendar-server ReqCalUpdate at " + dateTimeNow.toTimeString() + " from " + @calendarUrl)
		$.ajax @calendarUrl,
			type: "GET"
			dataType: "text"
			crossDomain: true
			success: (data, textStatus, jqXHR) =>
				jsonText = jqXHR.responseText
				jsonData = $.parseJSON(jsonText)
				@calendarData = jsonData
				@numRefreshFailuresSinceSuccess = 0
				console.log "calendar-server Got calendar data"
				return
			error: (jqXHR, textStatus, errorThrown) =>

				console.log("calendar-server " + " CALENDAR AjaxFail Status = " + textStatus + " URL=" + @calendarUrl + " Error= " + errorThrown);

				App.LocalStorage.logEvent("CalLog", "AjaxFail Status = " + textStatus + " URL=" + @calendarUrl + " Error= " + errorThrown)
				console.log "calendar-server GetCalError " + "ReqCalAjaxFailed TextStatus = " + textStatus + " ErrorThrown = " + errorThrown
				@numRefreshFailuresSinceSuccess++
				setTimeout =>
					@requestCalUpdate
				, (if @numRefreshFailuresSinceSuccess is 1 then @firstRefreshAfterFailSecs * 1000 else @nextRefreshesAfterFailSecs * 1000)
				return
		return

	getCalData: ->
		return @calendarData

	getCalNumDays: ->
		return @calendarNumDays

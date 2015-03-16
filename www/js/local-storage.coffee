class LocalStorage

	@get: (key) ->
		rslt = null
		if window.Storage and window.JSON
			item = localStorage.getItem(key)
			rslt = JSON.parse(item) if item
		return rslt

	@set: (key, value) ->
		if window.Storage and window.JSON
			localStorage.setItem(key, JSON.stringify(value))
			return true
		return false

	@logEvent: (logKey, eventText) ->
		logData = @get(logKey)
		if logData?
			while logData.length > 10
				logData.shift()
		else
			logData = []
		now = new Date()
		logData.push
			timestamp: now
			eventText: eventText
		@set(logKey, logData)
		return

	@formatDate: (d) ->
		return d.getFullYear() + "/" + @padZero(d.getMonth()+1,2) + "/" + @padZero(d.getDate(),2) +
			" " + @padZero(d.getHours(),2) + ":" + @padZero(d.getMinutes(),2) + ":" + @padZero(d.getSeconds(),2)

	@padZero: (val, zeroes) ->
		return("00000000" + val).slice(-zeroes)

	@getEventsText: (logKey) ->
		logData = @get(logKey)
		if not logData?
			return ""
		outStr = ""
		for ev in logData
			outStr += ev.timestamp + " " + ev.eventText + "\n"
		return outStr

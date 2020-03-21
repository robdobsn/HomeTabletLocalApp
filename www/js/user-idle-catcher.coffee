class App.UserIdleCatcher
	constructor: (@interval, @cbFunction, @parent) ->
		@idleTime = 0
		$("html").mousemove =>
			@resetIdleTimer()
		$("html").keypress => 
			@resetIdleTimer()
		$("html").scroll => 
			@resetIdleTimer()
		window.addEventListener 'touchstart', =>
			@resetIdleTimer()
		setInterval =>
			@idleTime += 1
			if @idleTime >= @interval
				@idleTime = 0
				@cbFunction(@parent)
		, 1000

	resetIdleTimer: ->
		@idleTime = 0

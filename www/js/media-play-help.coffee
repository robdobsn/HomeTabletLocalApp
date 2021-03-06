class App.MediaPlayHelper
	constructor: (@soundsDict) ->
		@soundsLoaded = {}
		return

	getPhoneGapPath: ->
		path = window.location.pathname
		path = path.substr( path, path.length - 10 )
		if path.substr(-1) isnt '/'
			path = path + '/'
		return 'file://' + path

	play: (soundName) ->
		if soundName of @soundsDict
			bTryAudio = false
			if window.plugins and window.plugins.LowLatencyAudio
				try
					if soundName not of @soundsLoaded
						console.log "media-play-help Preloading audio " + soundName
						window.plugins.LowLatencyAudio.preloadAudio(soundName, @soundsDict[soundName], 1, 1, @onSuccess, @onErrorPreload)
						@soundsLoaded[soundName] = true
					console.log "media-play-help Playing audio"
					window.plugins.LowLatencyAudio.play(soundName, @onSuccess, @onErrorPlay)
				catch e
					bTryAudio = true
			else
				bTryAudio = true
			if bTryAudio
				try
					snd = new Audio(@soundsDict[soundName])
					snd.play()
				catch e
					console.log("media-play-help LowLatencyAudio and Audio both failed")
		return

	onSuccess: (result) ->
		console.log("media-play-help LowLatencyAudio success result = " + result )
		return

	onErrorPreload: (error) ->
		console.log("media-play-help LowLatencyAudio preload error = " + error )
		return

	onErrorPlay: (error) ->
		console.log("media-play-help LowLatencyAudio play error = " + error )
		return
		

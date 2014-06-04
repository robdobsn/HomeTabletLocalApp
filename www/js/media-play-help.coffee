class MediaPlayHelper
    constructor: (@soundsDict) ->
        @soundsLoaded = {}

    getPhoneGapPath: ->
        path = window.location.pathname
        path = path.substr( path, path.length - 10 )
        if path.substr(-1) isnt '/'
            path = path + '/'
        return 'file://' + path

    play: (soundName) ->
        if soundName of @soundsDict
            if soundName not of @soundsLoaded
                LowLatencyAudio.preloadAudio(soundName, @soundsDict[soundName], 1, @onSuccess, @onError)
            LowLatencyAudio.play(soundName, @onSuccess, @onError)

    onSuccess: (result) ->
        console.log("LLAUDIO result = " + result )

    onError: (error) ->
        console.log("LLAUDIO error = " + error )

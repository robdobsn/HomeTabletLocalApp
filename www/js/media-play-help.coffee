class MediaPlayHelper
    constructor: (@soundsDict) ->
        @players = {}
        for soundName, soundFile of @soundsDict
            try
                # This is for phonegap devices
                pth = @getPhoneGapPath() + soundFile
                plyr = new Media( pth )
                @players[soundName] = plyr
            catch e
                # This should work on a regular browser
                plyr = new Audio( soundFile )
                @players[soundName] = plyr

    getPhoneGapPath: ->
        path = window.location.pathname
        path = path.substr( path, path.length - 10 )
        if path.substr(-1) isnt '/'
            path = path + '/'
        return 'file://' + path

    play: (soundName) ->
        if soundName of @players
            plyr = @players[soundName]
            plyr.play()

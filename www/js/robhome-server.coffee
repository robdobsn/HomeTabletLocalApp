class App.RobHomeServer
    constructor: (@manager, @serverDef, @dataReadyCallback) ->
        @ACTIONS_URI = @serverDef.url + "/mainconfig"
        @numRefreshFailuresSinceSuccess = 0
        @firstRefreshAfterFailSecs = 10
        @nextRefreshesAfterFailSecs = 60
        return

    setReadyCallback: (@dataReadyCallback) ->
        return

    reqActions: ->
        console.log "WallTabletDebug Requesting RobHomeServer data from " + @ACTIONS_URI
        $.ajax @ACTIONS_URI,
            type: "GET"
            dataType: "json"
            crossDomain: true
            success: (data, textStatus, jqXHR) =>
                @processRecvdActions(data)
                # console.log "RobHomeServer data = " + JSON.stringify(@scenes)
                console.log "WallTabletDebug Received RobHomeServer data from " + @ACTIONS_URI
                @numRefreshFailuresSinceSuccess = 0
                App.LocalStorage.set(@ACTIONS_URI, data)
                return
            error: (jqXHR, textStatus, errorThrown) =>

                console.log("WallTabletDebug " + " RobHomeServer AjaxFail Status= " + textStatus + " URL= " + @ACTIONS_URI + " Error= " + errorThrown);

                App.LocalStorage.logEvent("RobLog", "AjaxFail Status= " + textStatus + " URL= " + @ACTIONS_URI + " Error= " + errorThrown)
                @numRefreshFailuresSinceSuccess++
                setTimeout =>
                    @getActionGroups
                , (if @numRefreshFailuresSinceSuccess is 1 then @firstRefreshAfterFailSecs * 1000 else @nextRefreshesAfterFailSecs * 1000)
                # Use stored data if available
                storedData = App.LocalStorage.get(@ACTIONS_URI)
                console.log "WallTabletDebug Getting data stored for " + @ACTIONS_URI + " result = " + storedData
                if storedData?
                    # console.log "Using stored data" + JSON.stringify(storedData)
                    console.log "WallTabletDebug Using stored data for " + @ACTIONS_URI
                    @processRecvdActions(storedData)
                return
        return

    processRecvdActions: (data) ->
        @scenes = @getScenes(data)
        @scenes.sort @sortByRoomName
        @dataReadyCallback(@serverDef.name, @scenes)

    sortByRoomName: (a, b) ->
        if a.groupName < b.groupName then return -1
        if a.groupName > b.groupName then return 1
        return 0

    getScenes: (data, rooms) ->
        scenes = []
        serverScenes = data.scenes
        console.log "RobHomeServer data = " + JSON.stringify(serverScenes)
        if serverScenes?
            for serverScene in serverScenes
                actionName = serverScene.room + " - " + serverScene.nom
                scene = 
                    actionNum: ""
                    actionName: serverScene.room + " " + serverScene.nom
                    groupName: serverScene.room
                    actionUrl: serverScene.urls.join(";")
                    iconName: @manager.getIconFromActionName(actionName, @serverDef.iconAliasing)
                scenes.push(scene)
                console.log "RobHomeServer scene " + JSON.stringify(scene)
        return scenes

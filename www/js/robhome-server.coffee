class App.RobHomeServer
    constructor: (@manager, @serverDef, @dataReadyCallback) ->
        @ACTIONS_URI = @serverDef.url + "/scenes"
        @numRefreshFailuresSinceSuccess = 0
        @firstRefreshAfterFailSecs = 10
        @nextRefreshesAfterFailSecs = 60
        return

    setReadyCallback: (@dataReadyCallback) ->
        return

    reqActions: ->
        console.log "robhome-server Requesting RobHomeServer data from " + @ACTIONS_URI
        $.ajax @ACTIONS_URI,
            type: "GET"
            dataType: "json"
            crossDomain: true
            success: (data, textStatus, jqXHR) =>
                @processRecvdActions(data, true)
                @numRefreshFailuresSinceSuccess = 0
                App.LocalStorage.set(@ACTIONS_URI, data)
                return
            error: (jqXHR, textStatus, errorThrown) =>

                console.log("robhome-server " + " RobHomeServer AjaxFail Status= " + textStatus + " URL= " + @ACTIONS_URI + " Error= " + errorThrown);

                App.LocalStorage.logEvent("RobLog", "AjaxFail Status= " + textStatus + " URL= " + @ACTIONS_URI + " Error= " + errorThrown)
                @numRefreshFailuresSinceSuccess++
                setTimeout =>
                    @getActionGroups
                , (if @numRefreshFailuresSinceSuccess is 1 then @firstRefreshAfterFailSecs * 1000 else @nextRefreshesAfterFailSecs * 1000)
                # Use stored data if available
                storedData = App.LocalStorage.get(@ACTIONS_URI)
                console.log "robhome-server Getting data stored for " + @ACTIONS_URI + " result = " + storedData
                if storedData?
                    # console.log "Using stored data" + JSON.stringify(storedData)
                    console.log "robhome-server Using stored data for " + @ACTIONS_URI
                    @processRecvdActions(storedData, false)
                return
        return

    processRecvdActions: (data, fromURI) ->
        @scenes = @getScenes(data)
        @scenes.sort @sortByRoomName
        @dataReadyCallback(@serverDef.name, @scenes)
        console.log "robhome-server processRecvdActions from " + (if fromURI then @ACTIONS_URI else "STORAGE") + " #scenes " + @scenes.length

    sortByRoomName: (a, b) ->
        if a.groupName < b.groupName then return -1
        if a.groupName > b.groupName then return 1
        return 0

    getScenes: (data, rooms) ->
        scenes = []
        serverScenes = data.scenes
        # console.log "robhome-server RobHomeServer data = " + JSON.stringify(serverScenes)
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
                # console.log "robhome-server RobHomeServer scene " + JSON.stringify(scene)
        return scenes

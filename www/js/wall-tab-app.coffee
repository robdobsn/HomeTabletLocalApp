class WallTabApp
    constructor: ->
        @defaultTabletName = "tabdefault"
        @rdHomeServerUrl = "http://macallan:5000"
        @calendarUrl = "http://macallan:5077/calendar/min/4"
        @automationActionsUrl = @rdHomeServerUrl + "/automation/api/v1.0/actions"
        @automationExecUrl = @rdHomeServerUrl
        @sonosActionsUrl = ""
        @tabletConfigUrl = "http://localhost:5076/tabletconfig"
        @tabletLogUrl = "http://localhost:5076/log"
        @indigoServerUrl = "http://IndigoServer.local:8176"
        @indigo2ServerUrl = "http://IndigoDown.local:8176"
        @fibaroServerUrl = "http://macallan:5079"
        @veraServerUrl = "http://192.168.0.206:3480"
        @mediaPlayHelper = new MediaPlayHelper(
            {
                "click": "assets/click.mp3",
                "ok": "assets/blip.mp3",
                "fail": "assets/fail.mp3"
            })
        @hoursBetweenActionUpdates = 12
        @minsBetweenEventLogChecks = 1
        @maxEventsPerLogSend = 50
        return

    go: ->
        # Basic body for DOM
        $("body").prepend """
            <div id="sqWrapper">
            </div>
            """

        # Goes back to home display after user idle timeout
        @userIdleCatcher = new UserIdleCatcher(90, @actionOnUserIdle)

        # Manage ui grouping (rooms, action-groups, etc)
        @automationActionGroups = []

        # Communication with Vera3 & Indigo through automation server
        @automationServer = new AutomationServer(@automationActionsUrl, @automationExecUrl, @veraServerUrl, @indigoServerUrl, @indigo2ServerUrl, @fibaroServerUrl, @sonosActionsUrl, @mediaPlayHelper)
        @automationServer.setReadyCallback(@automationServerReadyCb)

        # Tablet config is based on the name or IP address of the tablet
        @tabletConfigServer = new TabletConfig @tabletConfigUrl, @defaultTabletName
        @tabletConfigServer.setReadyCallback(@tabletConfigReadyCb)

        # App Pages
        @appPages = new AppPages "#sqWrapper", @automationServer.executeCommand, @mediaPlayHelper, @tabletConfigServer

        # Handler for orientation change
        $(window).on 'orientationchange', =>
          @buildAndDisplayUI()

        # And resize event
        $(window).on 'resize', =>
          @buildAndDisplayUI()

        # Check event logs frequently
        @checkEventLogs()
        setInterval =>
            @checkEventLogs()
        , (@minsBetweenEventLogChecks * 60 * 1000)

        # Make initial requests for action (scene) data and config data and repeat requests at intervals
        @requestActionAndConfigData()
        setInterval =>
            @requestActionAndConfigData()
        , (@hoursBetweenActionUpdates * 60 * 60 * 1000)
        return

    requestActionAndConfigData: ->
        @automationServer.getActionGroups()
        return @tabletConfigServer.requestConfig()

    buildAndDisplayUI: ->
        @appPages.build(@automationActionGroups)
        @appPages.display()

    tabletConfigReadyCb: =>
        @buildAndDisplayUI()

    automationServerReadyCb: (actions, serverType) =>
        # Callback when data received from the automation server (scenes/actions)
        if @checkActionGroupsChanged(@automationActionGroups, actions)
            @automationActionGroups = actions
            @buildAndDisplayUI()
        return

    checkActionGroupsChanged: (oldActionMap, newActionMap) ->
        # Deep object comparison to see if configuration has changed
        if Object.keys(oldActionMap).length isnt Object.keys(newActionMap).length then return true
        for servType, oldActions of oldActionMap
            if not (servType of newActionMap) then return true
            newActions = newActionMap[servType]
            if @checkActionsForServer(oldActions, newActions) then return true
        return false

    checkActionsForServer: (oldActions, newActions) ->
        if oldActions.length isnt newActions.length then return true
        for oldAction, j in oldActions
            newAction = newActions[j]
            if Object.keys(oldAction).length isnt Object.keys(newAction).length then return true
            for k, v of oldAction
                if not k of newAction then return true
                if v isnt newAction[k] then return true
        return false
        
    actionOnUserIdle: =>
        @appPages.userIsIdle()
        return

    # configTabNameClick: ->
    #     tabName = LocalStorage.get("DeviceConfigName")
    #     if not tabName?
    #         tabName = ""
    #     $("#tabnamefield").val(tabName)
    #     $("#tabnameok").unbind("click")
    #     $("#tabnameok").click ->
    #         LocalStorage.set("DeviceConfigName", $("#tabnamefield").val())
    #         $("#tabnameform").hide()
    #     $("#tabnameform").show()
    #     return

    checkEventLogs: ->
        evList = []
        logCats = ["CalLog", "IndLog", "CnfLog"]
        for logCat in logCats
            for i in [0...@maxEventsPerLogSend]
                ev = LocalStorage.getEvent(logCat)
                if ev?
                    console.log "Logging event from " + logCat + " = " + JSON.stringify(ev)
                    evList.push
                        logCat: logCat
                        timestamp: ev.timestamp
                        eventText: ev.eventText
                else
                    break
        if evList.length > 0
            evListJson = JSON.stringify(evList)
            $.ajax 
                url: @tabletLogUrl
                type: 'POST'
                data: evListJson
                contentType: "application/json"
                success: (data, status, response) =>
                    console.log "logged events success"
                    return
                error: (jqXHR, textStatus, errorThrown) =>
                    console.log ("Error log failed: " + textStatus + " " + errorThrown)
                    # If logging failed then re-log the events
                    for ev in evList
                        LocalStorage.logEvent(ev.logCat, ev.eventText, ev.timestamp)
                    return
        return


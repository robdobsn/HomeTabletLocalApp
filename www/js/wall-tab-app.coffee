class App.WallTabApp
    constructor: ->

        console.log "WallTabletDebug APPLICATION STARTING UP"

        # Default the tablet name and get the configuration server
        @defaultTabletName = "tabdefault"
        # Basic settings
        @hoursBetweenActionUpdates = 12
        @minsBetweenEventLogChecks = 1
        @maxEventsPerLogSend = 50
        # Helper for playing media files
        @mediaPlayHelper = new App.MediaPlayHelper(
            {
                "click": "assets/click.mp3",
                "ok": "assets/ok.mp3",
                "fail": "assets/fail-wah.mp3"
            })
        @tileColours = new App.TileColours
        return

    getLogServerUrl: ->
        return App.LocalStorage.get("ConfigServerUrl")+ "/log"

    go: ->
        # Goes back to home display after user idle timeout
        @userIdleCatcher = new App.UserIdleCatcher(90, @actionOnUserIdle)

        # Tablet config is based on the name or IP address of the tablet
        @tabletConfigManager = new App.TabletConfigManager(@defaultTabletName)
        @tabletConfigManager.setReadyCallback(@tabletConfigReadyCb)

        # Automation manager handles communicaton with automaion devices like
        # Indigo/vera/fibaro
        @automationManager = new App.AutomationManager(this, @automationManagerReadyCb)

        # Calendar server communications
        @calendarManager = new App.CalendarManager(this)

        # App Pages
        @appPages = new App.AppPages(this, "#sqWrapper", @automationManager)

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
        @requestConfigData()
        setInterval =>
            @requestConfigData()
        , (@hoursBetweenActionUpdates * 60 * 60 * 1000)
        return

    requestConfigData: ->
        # Request tablet configuration from config server
        return @tabletConfigManager.requestConfig()

    tabletConfigReadyCb: =>
        # Configuration data is available
        configData = @tabletConfigManager.getConfigData()
        if configData.common? and configData.common.calendar?
            @calendarManager.setConfig(configData.common.calendar)
        @automationManager.requestUpdate(configData)

    automationManagerReadyCb: (hasChanged) =>
        # Automation server data is available
        if hasChanged
            @buildAndDisplayUI()

    buildAndDisplayUI: ->
        @appPages.build(@automationManager.getActionGroups())
        @appPages.display()

    actionOnUserIdle: =>
        @appPages.userIsIdle()
        return

    checkEventLogs: ->
        evList = []
        logCats = ["CalLog", "IndLog", "CnfLog"]
        for logCat in logCats
            for i in [0...@maxEventsPerLogSend]
                ev = App.LocalStorage.getEvent(logCat)
                if ev?
                    console.log "WallTabletDebug Logging event from " + logCat + " = " + JSON.stringify(ev)
                    evList.push
                        logCat: logCat
                        timestamp: ev.timestamp
                        eventText: ev.eventText
                else
                    break
        if evList.length > 0
            evListJson = JSON.stringify(evList)
            console.log "WallTabletDebug Sending " + evList.length + " log event(s) to log server"
            $.ajax 
                url: @getLogServerUrl()
                type: 'POST'
                data: evListJson
                contentType: "application/json"
                success: (data, status, response) =>
                    console.log "WallTabletDebug logged events success"
                    return
                error: (jqXHR, textStatus, errorThrown) =>
                    console.log ("WallTabletDebug Error log failed: " + textStatus + " " + errorThrown)
                    # If logging failed then re-log the events
                    for ev in evList
                        App.LocalStorage.logEvent(ev.logCat, ev.eventText, ev.timestamp)
                    return
        return


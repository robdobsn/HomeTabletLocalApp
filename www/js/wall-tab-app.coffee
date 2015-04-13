class WallTabApp
    constructor: ->
        # Default the tablet name and get the configuration server
        @defaultTabletName = "tabdefault"
        # Basic settings
        @hoursBetweenActionUpdates = 12
        @minsBetweenEventLogChecks = 1
        @maxEventsPerLogSend = 50
        # Helper for playing media files
        @mediaPlayHelper = new MediaPlayHelper(
            {
                "click": "assets/click.mp3",
                "ok": "assets/blip.mp3",
                "fail": "assets/fail.mp3"
            })
        return

    getLogServerUrl: ->
        return LocalStorage.get("ConfigServerUrl")+ "/log"

    go: ->
        # Goes back to home display after user idle timeout
        @userIdleCatcher = new UserIdleCatcher(90, @actionOnUserIdle)

        # Tablet config is based on the name or IP address of the tablet
        @tabletConfigManager = new TabletConfigManager(@defaultTabletName)
        @tabletConfigManager.setReadyCallback(@tabletConfigReadyCb)

        # Automation manager handles communicaton with automaion devices like
        # Indigo/vera/fibaro
        @automationManager = new AutomationManager(this, @automationManagerReadyCb)

        # Calendar server communications
        @calendarManager = new CalendarManager(this)

        # App Pages
        @appPages = new AppPages(this, "#sqWrapper", @automationManager)

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
                url: @getLogServerUrl()
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


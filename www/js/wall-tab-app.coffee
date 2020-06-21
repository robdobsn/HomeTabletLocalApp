class App.WallTabApp
    constructor: ->

        @VERSION = "2.2.0"

        console.log "wall-tab-app APPLICATION STARTING UP " + @VERSION

        # Default the tablet name and get the configuration server
        @defaultTabletName = "tabhall"
        @defaultConfigServerUrl = "http://192.168.86.247:5076"

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

    getConfigServerUrl: ->
        configUrl = App.LocalStorage.get("ConfigServerUrl")
        if !(configUrl?) || (configUrl.length == 0)
            console.log("wall-tab-app App.getConfigServerUrl from localstorage empty so using " + @defaultConfigServerUrl)
            configUrl = @defaultConfigServerUrl
        return configUrl

    getLogServerUrl: ->
        return @getConfigServerUrl() + "/log"

    go: ->
        # Goes back to home display after user idle timeout
        @userIdleCatcher = new App.UserIdleCatcher(90, @actionOnUserIdle, this)

        # Tablet config is based on the name or IP address of the tablet
        @tabletConfigManager = new App.TabletConfigManager(@defaultTabletName, @defaultConfigServerUrl)
        @tabletConfigManager.setReadyCallback(@tabletConfigReadyCb)

        # App updater
        @appUpdater = new App.AppUpdater(this, @getConfigServerUrl() + "/deployota/WallTabletApp")

        # Automation manager handles communicaton with automaion devices like
        # Indigo/vera/fibaro
        @automationManager = new App.AutomationManager(this, @automationManagerReadyCb)

        # Calendar server communications
        @calendarManager = new App.CalendarManager(this)

        # App Pages
        @appPages = new App.AppPages(this, "#sqWrapper", @automationManager, @VERSION)

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
        return

    automationManagerReadyCb: (hasChanged) =>
        # Automation server data is available
        if hasChanged
            @buildAndDisplayUI()
        return

    buildAndDisplayUI: ->
        @appPages.build(@automationManager.getActionGroups())
        @appPages.display()
        return

    actionOnUserIdle: (appObject) ->
        console.log "wall-tab-app actionOnUserIdle @appPages " + appObject
        appObject.appPages.userIsIdle()
        return

    checkEventLogs: ->
        evList = []
        logCats = ["CalLog", "IndLog", "CnfLog"]
        for logCat in logCats
            for i in [0...@maxEventsPerLogSend]
                ev = App.LocalStorage.getEvent(logCat)
                if ev?
                    console.log "wall-tab-app Logging event from " + logCat + " = " + JSON.stringify(ev)
                    evList.push
                        logCat: logCat
                        timestamp: ev.timestamp
                        eventText: ev.eventText
                else
                    break
        if evList.length > 0
            evListJson = JSON.stringify(evList)
            console.log "wall-tab-app Sending " + evList.length + " log event(s) to log server"
            $.ajax 
                url: @getLogServerUrl()
                type: 'POST'
                data: evListJson
                contentType: "application/json"
                success: (data, status, response) =>
                    console.log "wall-tab-app logged events success"
                    return
                error: (jqXHR, textStatus, errorThrown) =>
                    console.log ("wall-tab-app Error log failed: " + textStatus + " " + errorThrown)
                    # If logging failed then re-log the events
                    for ev in evList
                        App.LocalStorage.logEvent(ev.logCat, ev.eventText, ev.timestamp)
                    return
        return

    appUpdate: ->
        console.log ("wall-tab-app App update requested")
        @appUpdater.appUpdate()
        return


class WallTabApp
    constructor: ->
        @tileColours = new TileColours
#        @rdHomeServerUrl = "http://127.0.0.1:5000"
#        @rdHomeServerUrl = "http://192.168.0.97:5000"
        @rdHomeServerUrl = "http://macallan:5000"
        @calendarUrl = "http://macallan:5077/calendar/min/4"
        @automationActionsUrl = @rdHomeServerUrl + "/automation/api/v1.0/actions"
        @automationExecUrl = @rdHomeServerUrl
        @sonosActionsUrl = ""
        @tabletConfigUrl = "http://macallan:5076/tabletconfig"
        @tabletLogUrl = "http://macallan:5076/log"
        @indigoServerUrl = "http://IndigoServer.local:8176"
        @indigo2ServerUrl = "http://IndigoDown.local:8176"
        @fibaroServerUrl = "http://macallan:5079"
        @veraServerUrl = "http://192.168.0.206:3480"
        @jsonConfig = {}
        @mediaPlayHelper = new MediaPlayHelper(
            {
                "click": "assets/click.mp3",
                "ok": "assets/blip.mp3",
                "fail": "assets/fail.mp3"
            })
        @lastScrollEventTime = 0
        @minTimeBetweenScrolls = 1000
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

        # Scrolls back to most important panels on left of display after user idle timeout
        @userIdleCatcher = new UserIdleCatcher(30, @actionOnUserIdle)

        # Default config for tablet (overridden with info from tablet config server if available)
        @setDefaultTabletConfig()

        # Manage ui grouping (rooms, action-groups, etc)
        @automationActionGroups = []

        # Communication with Vera3 & Indigo through automation server
        @automationServer = new AutomationServer(@automationActionsUrl, @automationExecUrl, @veraServerUrl, @indigoServerUrl, @indigo2ServerUrl, @fibaroServerUrl, @sonosActionsUrl, @mediaPlayHelper, @navigateTo)
        @automationServer.setReadyCallback(@automationServerReadyCb)

        # Tablet config is based on the IP address of the tablet
        @tabletConfig = new TabletConfig @tabletConfigUrl
        @tabletConfig.setReadyCallback(@configReadyCb)

        # Tile tiers
        @tileTiers = new TileTiers "#sqWrapper"

        # Handler for orientation change
        $(window).on 'orientationchange', =>
          @tileTiers.reDoLayout()

        # And resize event
        $(window).on 'resize', =>
          @tileTiers.reDoLayout()

        # Rebuild UI
        @rebuildUI()

        # Add scroll snapping
        $(document).scrollsnap(
            snaps: '.snap',
            proximity: 250
            )

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
        return @tabletConfig.requestConfig()

    setDefaultTabletConfig: () ->
        groupDefinitions =
            [
                { tierName: "mainTier", groupName: "Home" },
                { tierName: "mainTier", groupName: "Calendar" },
                { tierName: "actionsTier", groupName: "Lights" },
                { tierName: "sonosTier", groupName: "Sonos" },
                { tierName: "sonosTier", groupName: "Kids" },
                { tierName: "doorBlindsTier", groupName: "Front Door" },
                { tierName: "calendarTier", groupName: "Today" },
            ]
        @jsonConfig["groupDefinitions"] = groupDefinitions
        tileDefinitions = 
            [
                # Calendar
                { tierName: "mainTier", groupName: "Calendar", colSpan: 2, rowSpan: 2, uri: "~~~calendarTier", name: "calendar", visibility: "landscape", tileType: "calendar", iconName: "none", calDayIndex: 0 }
                { tierName: "mainTier", groupName: "Home", colSpan: 3, rowSpan: 1, uri: "~~~calendarTier", name: "calendar", visibility: "portrait", tileType: "calendar", iconName: "none", calDayIndex: 0 }
                { tierName: "calendarTier", groupName: "Today", colSpan: 2, rowSpan: 3, uri: "", name: "calendar", visibility: "landscape", tileType: "calendar", iconName: "none", calDayIndex: 0 }
                { tierName: "calendarTier", groupName: "Tomorrow", colSpan: 2, rowSpan: 3, uri: "", name: "calendar", visibility: "landscape", tileType: "calendar", iconName: "none", calDayIndex: 1 }
                { tierName: "calendarTier", groupName: "Today + 2", colSpan: 2, rowSpan: 3, uri: "", name: "calendar", visibility: "landscape", tileType: "calendar", iconName: "none", calDayIndex: 2 }
                { tierName: "calendarTier", groupName: "Today + 3", colSpan: 2, rowSpan: 3, uri: "", name: "calendar", visibility: "landscape", tileType: "calendar", iconName: "none", calDayIndex: 3 }
                { tierName: "calendarTier", groupName: "Today + 4", colSpan: 2, rowSpan: 3, uri: "", name: "calendar", visibility: "landscape", tileType: "calendar", iconName: "none", calDayIndex: 4 }
                { tierName: "calendarTier", groupName: "Today", colSpan: 3, rowSpan: 5, uri: "", name: "calendar", visibility: "portrait", tileType: "calendar", iconName: "none", calDayIndex: 0 }
                { tierName: "calendarTier", groupName: "Tomorrow", colSpan: 3, rowSpan: 5, uri: "", name: "calendar", visibility: "portrait", tileType: "calendar", iconName: "none", calDayIndex: 1 }
                { tierName: "calendarTier", groupName: "Today + 2", colSpan: 3, rowSpan: 5, uri: "", name: "calendar", visibility: "portrait", tileType: "calendar", iconName: "none", calDayIndex: 2 }
                { tierName: "calendarTier", groupName: "Today + 3", colSpan: 3, rowSpan: 5, uri: "", name: "calendar", visibility: "portrait", tileType: "calendar", iconName: "none", calDayIndex: 3 }
                { tierName: "calendarTier", groupName: "Today + 4", colSpan: 3, rowSpan: 5, uri: "", name: "calendar", visibility: "portrait", tileType: "calendar", iconName: "none", calDayIndex: 4 }
                # Clock
                { tierName: "mainTier", groupName: "Calendar", colSpan: 2, rowSpan: 1, uri: "", name: "clock", visibility: "landscape", tileType: "clock", iconName: "none"}
                { tierName: "mainTier", groupName: "Home", colSpan: 3, rowSpan: 1, uri: "", name: "clock", visibility: "portrait", tileType: "clock", iconName: "none"}
                # Config
                { tierName: "mainTier", groupName: "Config", colSpan: 1, rowSpan: 1, uri: "", name: "TabName", visibility: "all", tileType: "config", iconName: "config", configType: "tabname", clickFn: @configTabNameClick, groupPriority: 0 }
            ]
        @jsonConfig["tileDefs_static"] = tileDefinitions
        return

    makeTileFromTileDef: (tileDef) ->
        if tileDef.tileType is "calendar"
            @makeCalendarTile(tileDef)
        else if tileDef.tileType is "clock"
            @makeClockTile(tileDef)
        else if tileDef.tileType is "config"
            @makeConfigTile(tileDef)
        else
            @makeSceneTile(tileDef)
        return

    tileBasicsFromDef: (tileDef) ->
        tileColour = @tileColours.getNextColour()
        tierIdx = @tileTiers.findTierIdx(tileDef.tierName)
        if tierIdx < 0 then return null
        isFavourite = true if tileDef.isFavourite? and tileDef.isFavourite
        clickFn = @automationServer.executeCommand
        if "clickFn" of tileDef
            clickFn = tileDef.clickFn
        tileBasics = new TileBasics tileColour, tileDef.colSpan, tileDef.rowSpan, clickFn, tileDef.uri, tileDef.name, tileDef.visibility, @tileTiers.getTileTierSelector(tileDef.tierName), tileDef.tileType, tileDef.iconName, isFavourite, @mediaPlayHelper
        return tileBasics

    makeCalendarTile: (tileDef) ->
        tileBasics = @tileBasicsFromDef(tileDef)
        if tileBasics is null then return
        tile = new CalendarTile tileBasics, @calendarUrl, tileDef.calDayIndex
        @addTileToTierGroup(tileDef, tile)
        return

    makeClockTile: (tileDef) ->
        tileBasics = @tileBasicsFromDef(tileDef)
        if tileBasics is null then return
        tile = new Clock tileBasics
        @addTileToTierGroup(tileDef, tile)
        return

    makeConfigTile: (tileDef) ->
        tileBasics = @tileBasicsFromDef(tileDef)
        if tileBasics is null then return
        tile = new ConfigTile tileBasics, tileDef.configType
        @addTileToTierGroup(tileDef, tile)
        return

    makeSceneTile: (tileDef) ->
        tileBasics = @tileBasicsFromDef(tileDef)
        if tileBasics is null then return
        tile = new SceneButton tileBasics, tileDef.name
        @addTileToTierGroup(tileDef, tile)
        return

    addTileToTierGroup: (tileDef, tile) ->
        tierName = tileDef.tierName
        groupName = tileDef.groupName
        groupPriority = if "groupPriority" of tileDef then tileDef.groupPriority else 5
        tierIdx = @tileTiers.findTierIdx(tierName)
        if tierIdx < 0 then tierIdx = @tileTiers.findTierIdx("actionsTier")
        if tierIdx < 0 then return
        if groupName is "" then groupName = "Lights"
        groupIdx = @getUIGroupIdxAddGroupIfReqd(tierIdx, groupName, groupPriority)
        #groupIdx = @tileTiers.findGroupIdx(tierIdx, groupName)
        #if groupIdx < 0 then return
        @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)
        return

    rebuildUI: =>
        # Remove all tiers and reapply tiers/groups config
        @tileTiers.removeAll()
        @applyTierAndGroupConfig(@jsonConfig)
        # Create tiles for all actions/scenes
        for servType, actionList of @automationActionGroups
            for action in actionList
                # make the button
                tierName = if "tierName" of action then action.tierName else "actionsTier"
                iconName = if "iconName" of action then action.iconName else ""
                tileDef = { tierName: tierName, groupName: action.groupName, colSpan: 1, rowSpan: 1, uri: action.actionUrl, name: action.actionName, visibility: "all", tileType: "action", iconName: iconName }
                @makeTileFromTileDef(tileDef)
        # Re-apply the configuration for the tablet - handles favourites group etc
        @applyTileConfig(@jsonConfig)
        # Re-do the layout of tiles
        @tileTiers.reDoLayout()
        return

    getUIGroupIdxAddGroupIfReqd: (tierIdx, groupName, groupPriority) ->
        # Get ui group for the scene
        if groupName is "" then return -1
        groupIdx = @tileTiers.findGroupIdx(tierIdx, groupName)
        if groupIdx < 0
            # Make a new ui group if the room/action-group name is unknown
            groupIdx = @tileTiers.addGroup tierIdx, groupName, groupPriority
        return groupIdx

    applyTierAndGroupConfig: (jsonConfig) ->
        for groupDef in jsonConfig.groupDefinitions
            tierIdx = @tileTiers.findTierIdx(groupDef.tierName)
            if tierIdx < 0
                newTier = new TileTier "#sqWrapper", groupDef.tierName
                newTier.addToDom()
                tierIdx = @tileTiers.addTier(newTier)
            groupPriority = if "groupPriority" of groupDef then groupDef.groupPriority else 5
            groupIdx = @getUIGroupIdxAddGroupIfReqd(tierIdx, groupDef.groupName, groupPriority)
        return

    applyTileConfig: (jsonConfig) ->
        # Go through the config groups
        favourites = {}
        for key,val of jsonConfig
            if key is "favourites"
                favourites = val
            else if key.search(/tileDefs_/) is 0
                for tileDef in val
                    @makeTileFromTileDef(tileDef)
        for favouriteDefn in favourites
            # Find existing tile matching the description
            exTile = @tileTiers.findExistingTile(favouriteDefn.tileName, favouriteDefn.groupName)
            if exTile isnt null
                tb = exTile.tileBasics
                destGroupName = if "destGroup" of favouriteDefn then favouriteDefn["destGroup"] else "Home"
                tileDef = { tierName: "mainTier", groupName: destGroupName, colSpan: tb.colSpan, rowSpan: tb.rowSpan, uri: tb.clickParam, name: tb.tileName, visibility: tb.visibility, tileType: tb.tileType, iconName: tb.iconName, isFavourite: true }
                @makeTileFromTileDef(tileDef)
        return

    configReadyCb: (inConfig) =>
        # Replace configuration info for keys that are present
        # but don't remove config info for keys that aren't
        for k,v of inConfig
            @jsonConfig[k] = v
        # Rebuild UI
        @rebuildUI()
        return

    automationServerReadyCb: (actions, serverType) =>
        # Callback when data received from the automation server (scenes/actions)
        if @checkActionGroupsChanged(@automationActionGroups, actions)
            @automationActionGroups = actions
            @rebuildUI()
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
        if $(window).scrollLeft() is 0 and $(window).scrollTop() < 20 then return
        console.log ("ScrollTop = " + $(window).scrollTop())
        $("html, body").animate({ scrollTop: "0px" }, 200).animate({ scrollLeft: "0px" }, 200);
        return

    navigateTo: (tierName) =>
        tierTop = @tileTiers.getTierTop(tierName)
        if tierTop >= 0
            $("html, body").stop().animate({ scrollTop: tierTop }, 200);
        return

    configTabNameClick: ->
        tabName = LocalStorage.get("DeviceConfigName")
        if not tabName?
            tabName = ""
        $("#tabnamefield").val(tabName)
        $("#tabnameok").unbind("click")
        $("#tabnameok").click ->
            LocalStorage.set("DeviceConfigName", $("#tabnamefield").val())
            $("#tabnameform").hide()
        $("#tabnameform").show()
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
                url: @tabletLogUrl
                type: 'POST'
                data: evListJson
                contentType: "application/json"
                success: (data, status, response) =>
                    console.log "logged events success"
                error: (jqXHR, textStatus, errorThrown) =>
                    console.error ("Error log failed: " + textStatus + " " + errorThrown)
                    # If logging failed then re-log the events
                    for ev in evList
                        LocalStorage.log(ev.logCat, ev.eventText, ev.timestamp)

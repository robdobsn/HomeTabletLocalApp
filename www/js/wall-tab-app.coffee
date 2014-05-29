class WallTabApp
    constructor: ->
        @tileColours = new TileColours
        @rdHomeServerUrl = "http://127.0.0.1:5000"
#        @rdHomeServerUrl = "http://192.168.0.97:5000"
#        @rdHomeServerUrl = "http://macallan:5000"
        @calendarUrl = @rdHomeServerUrl + "/calendars/api/v1.0/cal"
        @automationActionsUrl = @rdHomeServerUrl + "/automation/api/v1.0/actions"
        @automationExecUrl = @rdHomeServerUrl
        @sonosActionsUrl = @rdHomeServerUrl + "/sonos/api/v1.0/actions"
        @tabletConfigUrl = @rdHomeServerUrl + "/tablet/api/v1.0/config"
        @indigoServerUrl = "http://IndigoServer.local:8176"
        @fibaroServerUrl = "http://192.168.0.69"
        @veraServerUrl = "http://192.168.0.206:3480"
        @frontDoorUrl = "http://192.168.0.221/"
        @jsonConfig = {}

    go: ->
        # Basic body for DOM
        $("body").append """
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
        @automationServer = new AutomationServer(@automationActionsUrl, @automationExecUrl, @veraServerUrl, @indigoServerUrl, @fibaroServerUrl, @sonosActionsUrl)
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

        # Make initial requests for action (scene) data and config data and repeat requests at intervals
        @requestActionAndConfigData()
        setInterval =>
            @requestActionAndConfigData()
        , 600000

    requestActionAndConfigData: ->
        @automationServer.getActionGroups()
        @tabletConfig.initTabletConfig()

    setDefaultTabletConfig: () ->
        groupDefinitions =
            [
                { tierName: "mainTier", groupName: "Home" },
                { tierName: "mainTier", groupName: "Calendar" },
                { tierName: "actionsTier", groupName: "Lights" },
                { tierName: "sonosTier", groupName: "Kitchen" },
                { tierName: "doorBlindsTier", groupName: "Front Door" },
            ]
        @jsonConfig["groupDefinitions"] = groupDefinitions
        tileDefinitions = 
            [
                # Calendar
                { tierName: "mainTier", groupName: "Calendar", colSpan: 2, rowSpan: 2, uri: "", name: "calendar", visibility: "all", tileType: "calendar", iconName: "none", calDayIndex: 0 }
                # Clock
                { tierName: "mainTier", groupName: "Calendar", colSpan: 2, rowSpan: 1, uri: "", name: "clock", visibility: "all", tileType: "clock", iconName: "none"}
            ]
        @jsonConfig["tileDefinitions"] = tileDefinitions

    makeTileFromTileDef: (tileDef) ->
        if tileDef.tileType is "calendar"
            @makeCalendarTile(tileDef)
        else if tileDef.tileType is "clock"
            @makeClockTile(tileDef)
        else
            @makeSceneTile(tileDef)

    tileBasicsFromDef: (tileDef) ->
        tileColour = @tileColours.getNextColour()
        tierIdx = @tileTiers.findTierIdx(tileDef.tierName)
        if tierIdx < 0 then return null
        tileBasics = new TileBasics tileColour, tileDef.colSpan, tileDef.rowSpan, @automationServer.executeCommand, tileDef.uri, tileDef.name, tileDef.visibility, @tileTiers.getTileTierSelector(tileDef.tierName), tileDef.tileType, tileDef.iconName

    makeCalendarTile: (tileDef) ->
        tileBasics = @tileBasicsFromDef(tileDef)
        if tileBasics is null then return
        tile = new CalendarTile tileBasics, @calendarUrl, tileDef.calDayIndex
        @addTileToTierGroup(tileDef.tierName, tileDef.groupName, tile)

    makeClockTile: (tileDef) ->
        tileBasics = @tileBasicsFromDef(tileDef)
        if tileBasics is null then return
        tile = new Clock tileBasics
        @addTileToTierGroup(tileDef.tierName, tileDef.groupName, tile)

    makeSceneTile: (tileDef) ->
        tileBasics = @tileBasicsFromDef(tileDef)
        if tileBasics is null then return
        tile = new SceneButton tileBasics, tileDef.name
        @addTileToTierGroup(tileDef.tierName, tileDef.groupName, tile)

    addTileToTierGroup: (tierName, groupName, tile) ->
        tierIdx = @tileTiers.findTierIdx(tierName)
        if tierIdx < 0 then tierIdx = @tileTiers.findTierIdx("actionsTier")
        if tierIdx < 0 then return
        if groupName is "" then groupName = "Lights"
        groupIdx = @getUIGroupIdxAddGroupIfReqd(tierIdx, groupName)
        #groupIdx = @tileTiers.findGroupIdx(tierIdx, groupName)
        #if groupIdx < 0 then return
        @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)

    rebuildUI: =>
        # Remove all tiers and reapply tiers/groups config
        @tileTiers.removeAll()
        @applyTierAndGroupConfig(@jsonConfig)
        # Create tiles for all actions/scenes
        for servType, actionList of @automationActionGroups
            for action in actionList
                # make the button
                tierName = if "tierName" of action then action.tierName else "actionsTier"
                tileDef = { tierName: tierName, groupName: action.groupName, colSpan: 1, rowSpan: 1, uri: action.actionUrl, name: action.actionName, visibility: "all", tileType: "action", iconName: if "iconName" of action then action.iconName else "bulb-on" }
                @makeTileFromTileDef(tileDef)
        # Re-apply the configuration for the tablet - handles favourites group etc
        @applyTileConfig(@jsonConfig)
        # Re-do the layout of tiles
        @tileTiers.reDoLayout()

    getUIGroupIdxAddGroupIfReqd: (tierIdx, groupName) ->
        # Get ui group for the scene
        if groupName is "" then return -1
        groupIdx = @tileTiers.findGroupIdx(tierIdx, groupName)
        if groupIdx < 0
            # Make a new ui group if the room/action-group name is unknown
            groupIdx = @tileTiers.addGroup tierIdx, groupName
        return groupIdx

    applyTierAndGroupConfig: (jsonConfig) ->
        for groupDef in jsonConfig.groupDefinitions
            tierIdx = @tileTiers.findTierIdx(groupDef.tierName)
            if tierIdx < 0
                newTier = new TileTier "#sqWrapper", groupDef.tierName
                newTier.addToDom()
                tierIdx = @tileTiers.addTier(newTier)
            groupIdx = @getUIGroupIdxAddGroupIfReqd(tierIdx, groupDef.groupName)

    applyTileConfig: (jsonConfig) ->
        # Make tiles free-form
        if "tileDefinitions" of jsonConfig
            for tileDef in jsonConfig.tileDefinitions
                @makeTileFromTileDef(tileDef)
        # Copy tiles that should be in favourites group                
        if "favourites" of jsonConfig
            for favouriteDefn in jsonConfig.favourites
                # Find existing tile matching the description
                exTile = @tileTiers.findExistingTile(favouriteDefn.tileName)
                if exTile isnt null
                    tb = exTile.tileBasics
                    tileDef = { tierName: "mainTier", groupName: "Home", colSpan: tb.colSpan, rowSpan: tb.rowSpan, uri: tb.clickParam, name: tb.tileName, visibility: tb.visibility, tileType: tb.tileType, iconName: tb.iconName }
                    @makeTileFromTileDef(tileDef)
        return

    configReadyCb: (inConfig) =>
        # Replace configuration info for keys that are present
        # but don't remove config info for keys that aren't
        for k,v of inConfig
            @jsonConfig[k] = v
        # Rebuild UI
        @rebuildUI()

    automationServerReadyCb: (actions, serverType) =>
        # Callback when data received from the automation server (scenes/actions)
        if @checkActionGroupsChanged(@automationActionGroups, actions)
            @automationActionGroups = actions
            @rebuildUI()

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
        for j in [0..oldActions.length-1]
            oldAction = oldActions[j]
            newAction = newActions[j]
            if Object.keys(oldAction).length isnt Object.keys(newAction).length then return true
            for k, v of oldAction
                if not k of newAction then return true
                if v isnt newAction[k] then return true
        return false

    actionOnUserIdle: =>
        $("html, body").animate({ scrollLeft: "0px" });

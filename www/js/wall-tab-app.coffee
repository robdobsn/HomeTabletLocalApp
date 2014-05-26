class WallTabApp
    constructor: ->
        @tileColours = new TileColours
#        @rdHomeServerUrl = "http://127.0.0.1:5000"
#        @rdHomeServerUrl = "http://192.168.0.97:5000"
        @rdHomeServerUrl = "http://macallan:5000"
        @calendarUrl = @rdHomeServerUrl + "/calendars/api/v1.0/cal"
        @automationServerUrl = @rdHomeServerUrl + "/automation/api/v1.0"
        @tabletConfigUrl = @rdHomeServerUrl + "/tablet/api/v1.0/config"
        @indigoServerUrl = "http://IndigoServer.local:8176"
        @veraServerUrl = "http://192.168.0.206:3480"
        @frontDoorUrl = "http://192.168.0.221/"
        @blindsActions = GetBlindsActions()
        @jsonConfig = {}
        @doorActions = 
        [
            { actionNum: 0, actionName: "Main Unlock", groupName: "Front Door", actionUrl: @frontDoorUrl + "main-unlock" },
            { actionNum: 0, actionName: "Main Lock", groupName: "Front Door", actionUrl: @frontDoorUrl + "main-lock" },
            { actionNum: 0, actionName: "Inner Unlock", groupName: "Front Door", actionUrl: @frontDoorUrl + "inner-unlock" },
            { actionNum: 0, actionName: "Inner Lock", groupName: "Front Door", actionUrl: @frontDoorUrl + "inner-lock" }
        ]

    go: ->
        # Basic body for DOM
        $("body").append """
            <div id="sqWrapper">
            </div>
            """

        # Scrolls back to most important panels on left of display after user idle timeout
        @userIdleCatcher = new UserIdleCatcher(30, @actionOnUserIdle)

        # Manage ui grouping (rooms, action-groups, etc)
        @automationActionGroups = []
        @uiGroupMapping = {}

        # Communication with Vera3 & Indigo through automation server
        @automationServer = new AutomationServer(@automationServerUrl, @veraServerUrl, @indigoServerUrl, @blindsActions, @doorActions)
        @automationServer.setReadyCallback(@automationServerReadyCb)

        # Tablet config is based on the IP address of the tablet
        @tabletConfig = new TabletConfig @tabletConfigUrl
        @tabletConfig.setReadyCallback(@configReadyCb)

        # Tile tiers
        @tileTiers = new TileTiers "#sqWrapper"

        # Main tier
        mainTier = new TileTier "#sqWrapper", "_Tier1"
        mainTier.addToDom()
        @tileTiers.addTier (mainTier)

        # Favourites group
        @favouritesTierIdx = 0
        @favouritesGroupIdx = @tileTiers.addGroup @favouritesTierIdx, "Home"

        # Calendar group
        @calendarTierIdx = 0
        @calendarGroupIdx = @tileTiers.addGroup @calendarTierIdx, "Calendar"

        # Scenes group
        @sceneTierIdx = 0
        @sceneGroupIdx = @tileTiers.addGroup @sceneTierIdx, "Scenes"

        # Second tier
        secondTier = new TileTier "#sqWrapper", "_Tier2"
        secondTier.addToDom()
        @tileTiers.addTier (secondTier)

        # Sonos group
        @sonosTierIdx = 1
        @sonosGroupIdx = @tileTiers.addGroup @sonosTierIdx, "Sonos"

        # Initial UI layout
        @tileTiers.clear()
        @setupClockAndCalendar(false)

        # Handler for orientation change
        $(window).on 'orientationchange', =>
          @tileTiers.reDoLayout()

        # And resize event
        $(window).on 'resize', =>
          @tileTiers.reDoLayout()

        # Make initial requests for action (scene) data and config data and repeat requests at intervals
        @requestActionAndConfigData()
        setInterval =>
            @requestActionAndConfigData()
        , 600000

    requestActionAndConfigData: ->
        @automationServer.getActionGroups()
        @tabletConfig.initTabletConfig()
    
    addClock: (tierIdx, groupIdx) ->
        visibility = "all"
        tileBasics = new TileBasics @tileColours.getNextColour(), 3, 1, null, "", "clock", visibility, @tileTiers.getTileContainerSelector(tierIdx)
        tile = new Clock tileBasics
        @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)

    addCalendar: (tierIdx, onlyAddToGroupIdx = null) ->
        calG = @calendarGroupIdx
        favG = @favouritesGroupIdx
        lands = "landscape"
        portr = "portrait"
        calendarTileDefs = []
        calendarTileDefs.push new CalendarTileDefiniton lands, calG, 2, 2, 0
        calendarTileDefs.push new CalendarTileDefiniton lands, calG, 2, 1, 1
        calendarTileDefs.push new CalendarTileDefiniton portr, favG, 3, 2, 0
        calendarTileDefs.push new CalendarTileDefiniton portr, calG, 3, 2, 1
        calendarTileDefs.push new CalendarTileDefiniton portr, calG, 3, 2, 2
        calendarTileDefs.push new CalendarTileDefiniton portr, calG, 3, 1, 3
        for ctd in calendarTileDefs
            if not (onlyAddToGroupIdx? and (onlyAddToGroupIdx isnt ctd.groupIdx))
                tileBasics = new TileBasics @tileColours.getNextColour(), ctd.colSpan, ctd.rowSpan, null, "", "calendar", ctd.visibility, @tileTiers.getTileContainerSelector(tierIdx)
                tile = new CalendarTile tileBasics, @calendarUrl, ctd.calDayIndex
                @tileTiers.addTileToTierGroup(tierIdx, ctd.groupIdx, tile)

    setupClockAndCalendar: (bFavouritesOnly) ->
        # Add the clock and calendar back in
        if bFavouritesOnly
            @addClock(@favouritesTierIdx, @favouritesGroupIdx)
            @addCalendar(@calendarTierIdx)
        else
            @addClock(@favouritesTierIdx, @favouritesGroupIdx)
            @addCalendar(@calendarTierIdx, @favouritesGroupIdx)

    makeUriButton: (tierIdx, groupIdx, name, iconname, uri, colSpan, rowSpan, visibility = "all") ->
        tileBasics = new TileBasics @tileColours.getNextColour(), colSpan, rowSpan, "testCommand", uri, name, visibility, @tileTiers.getTileContainerSelector(tierIdx)
        tile = new SceneButton tileBasics, iconname, name
        @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)

    makeSceneButton: (tierIdx, groupIdx, name, uri, visibility = "all") ->
        tileBasics = new TileBasics @tileColours.getNextColour(), 1, 1, @automationServer.executeCommand, uri, name, visibility, @tileTiers.getTileContainerSelector(tierIdx)
        tile = new SceneButton tileBasics, "bulb-on", name
        @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)

    automationServerReadyCb: (actions, serverType) =>
        # Callback when data received from the automation server (scenes/actions)
        if @checkActionGroupsChanged(@automationActionGroups, actions)
            @automationActionGroups = actions
            @updateUIWithActionGroups()

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
        false

    updateUIWithActionGroups: =>
        # Clear all tiers initially
        @tileTiers.clear()
        @setupClockAndCalendar(false)
        # Create tiles for all actions/scenes
        for servType, actionList of @automationActionGroups
            for action in actionList
                # Get ui group for the scene
                groupIdx = @sceneGroupIdx
                if action.groupName isnt ""
                    if action.groupName of @uiGroupMapping
                        groupIdx = @uiGroupMapping[action.groupName]
                    else
                        # Make a new ui group if the room/action-group name is new
                        groupIdx = @tileTiers.addGroup @sceneTierIdx, action.groupName
                        @uiGroupMapping[action.groupName] = groupIdx
                # make the scene button
                @makeSceneButton @sceneTierIdx, groupIdx, action.actionName, action.actionUrl
        # Apply the configuration for the tablet - handles favourites group etc
        @applyJsonConfig @jsonConfig
        # Re-do the layout of tiles
        @tileTiers.reDoLayout()

    applyJsonConfig: (jsonConfig) ->
        # Clear just the favourites group (and add clock back in)
        @tileTiers.clearGroup(@favouritesTierIdx, @favouritesGroupIdx)
        @setupClockAndCalendar(true)
        # Copy tiles that should be in favourites group
        if "favourites" of jsonConfig
            for favouriteDefn in jsonConfig.favourites
                existingTile = @tileTiers.findExistingTile(@favouritesTierIdx, favouriteDefn.tileName)
                if existingTile isnt null
                    @makeSceneButton @favouritesTierIdx, @favouritesGroupIdx, favouriteDefn.tileName, existingTile.tileBasics.clickParam

    configReadyCb: (@jsonConfig) =>
        @applyJsonConfig(@jsonConfig)
        @tileTiers.reDoLayout()

    actionOnUserIdle: =>
        $("html, body").animate({ scrollLeft: "0px" });

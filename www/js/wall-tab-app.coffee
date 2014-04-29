class WallTabApp
    constructor: ->
        @tileColours = new TileColours
#        @rdHomeServerUrl = "http://192.168.0.97:5000"
        @rdHomeServerUrl = "http://macallan:5000"
        @calendarUrl = @rdHomeServerUrl + "/calendars/api/v1.0/cal"
        @automationServerUrl = @rdHomeServerUrl + "/automation/api/v1.0"
        @tabletConfigUrl = @rdHomeServerUrl + "/tablet/api/v1.0/config"
        @indigoServerUrl = "http://IndigoServer.local:8176"
        @veraServerUrl = "http://192.168.0.206:3480"
        @frontDoorUrl = "http://192.168.0.221/"
        @blindsActions = GetBlindsActions()
        @doorActions = [
            [ 0, "Main Unlock", "Front Door", @frontDoorUrl + "main-unlock" ],
            [ 0, "Main Lock", "Front Door", @frontDoorUrl + "main-lock" ],
            [ 0, "Inner Unlock", "Front Door", @frontDoorUrl + "inner-unlock" ],
            [ 0, "Inner Lock", "Front Door", @frontDoorUrl + "inner-lock" ]
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
        @tileTiers.addTier mainTier

        # Favourites group
        @favouritesGroupIdx = @tileTiers.addGroup 0, "Home"

        # Calendar group
        @calendarGroupIdx = @tileTiers.addGroup 0, "Calendar"

        # Scenes group
        @sceneGroupIdx = @tileTiers.addGroup 0, "Scenes"

        # Initial UI layout
        @setupInitialUI()
        @tileTiers.reDoLayout()

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
    
    addClock: (groupIdx) ->
        visibility = "all"
        tileBasics = new TileBasics @tileColours.getNextColour(), 3, null, "", "clock", visibility
        tile = new Clock tileBasics
        @tileTiers.addTileToTierGroup(0, groupIdx, tile)

    addCalendar: (onlyAddToGroupIdx = null) ->
        for orientation in [0..1]
            calG = @calendarGroupIdx
            favG = @favouritesGroupIdx
            if orientation is 0
                visibility = "all"
                groupInfo = [ calG, calG, calG ]
                calDayIdx = [ 0, 1, 2]
                colSpans = [ 2, 2, 2]
            else
                visibility = "portrait"
                groupInfo = [ favG, favG, calG, calG ]
                calDayIdx = [ 0, 1, 3, 4]
                colSpans = [ 3, 3, 2, 2]
            for i in [0..groupInfo.length-1]
                groupIdx = groupInfo[i]
                colSpan = colSpans[i]
                if not (onlyAddToGroupIdx? and (onlyAddToGroupIdx isnt groupIdx))
                    tileBasics = new TileBasics @tileColours.getNextColour(), colSpan, null, "", "calendar", visibility
                    tile = new CalendarTile tileBasics, @calendarUrl, calDayIdx[i]
                    @tileTiers.addTileToTierGroup(0, groupIdx, tile)

    makeSceneButton: (groupIdx, name, uri, visibility = "all") ->
        tileBasics = new TileBasics @tileColours.getNextColour(), 1, @automationServer.executeCommand, uri, name, visibility
        tile = new SceneButton tileBasics, "bulb-on", name
        @tileTiers.addTileToTierGroup(0, groupIdx, tile)

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
            if oldAction.length isnt newAction.length then return true
            for i in [0..oldAction.length-1]
                if oldAction[i] isnt newAction[i] then return true
        false

    setupInitialUI: ->
        # Clear all tiers initially
        @tileTiers.clear()
        # Add the clock and calendar back in
        @addClock(@favouritesGroupIdx)
        @addCalendar()

    updateUIWithActionGroups: =>
        @setupInitialUI()
        # Create tiles for all actions/scenes
        for servType, actionList of @automationActionGroups
            for action in actionList
                # Get ui group for the scene
                groupIdx = @sceneGroupIdx
                if action[2] isnt ""
                    if action[2] of @uiGroupMapping
                        groupIdx = @uiGroupMapping[action[2]]
                    else
                        # Make a new ui group if the room/action-group name is new
                        groupIdx = @tileTiers.addGroup 0, action[2]
                        @uiGroupMapping[action[2]] = groupIdx
                # make the scene button
                @makeSceneButton groupIdx, action[1], action[3]
        # Apply the configuration for the tablet - handles favourites group etc
        if @jsonConfig isnt null
            @applyJsonConfig @jsonConfig
        # Re-do the layout of tiles
        @tileTiers.reDoLayout()

    applyJsonConfig: (jsonConfig) ->
        # Clear just the favourites group (and add clock back in)
        @tileTiers.clearGroup(0, @favouritesGroupIdx)
        @addClock(@favouritesGroupIdx)
        @addCalendar(@favouritesGroupIdx)
        # Copy tiles that should be in favourites group
        for actionName, uiGroup of jsonConfig
            existingTile = @tileTiers.findExistingTile(0, actionName)
            if existingTile isnt null
                @makeSceneButton @favouritesGroupIdx, actionName, existingTile.tileBasics.clickParam

    configReadyCb: (@jsonConfig) =>
        @applyJsonConfig(@jsonConfig)
        @tileTiers.reDoLayout()

    actionOnUserIdle: =>
        $("html, body").animate({ scrollLeft: "0px" });

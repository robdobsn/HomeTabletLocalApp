class TestWallTabApp
    constructor: ->
        @tileColours = new TileColours

    go: ->
        # Basic body for DOM
        $("body").append """
            <div id="sqWrapper">
            </div>
            """

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
        @setupInitialUI()

        @makeUriButton(@favouritesTierIdx, @favouritesGroupIdx, "Test1", "musicicon", "/testuri1", 2, 2)

        @tileTiers.reDoLayout()

        # Handler for orientation change
        $(window).on 'orientationchange', =>
          @tileTiers.reDoLayout()

        # And resize event
        $(window).on 'resize', =>
          @tileTiers.reDoLayout()
  
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

    makeUriButton: (tierIdx, groupIdx, name, iconname, uri, colSpan, rowSpan, visibility = "all") ->
        tileBasics = new TileBasics @tileColours.getNextColour(), colSpan, rowSpan, "testCommand", uri, name, visibility, @tileTiers.getTileContainerSelector(tierIdx)
        tile = new SceneButton tileBasics, iconname, name
        @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)

    setupInitialUI: ->
        # Add the clock and calendar back in
        @addClock(@favouritesTierIdx, @favouritesGroupIdx)
        @addCalendar(@calendarTierIdx)

    actionOnUserIdle: =>
        $("html, body").animate({ scrollLeft: "0px" });

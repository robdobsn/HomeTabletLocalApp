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
        for orientation in [0..1]
            calG = @calendarGroupIdx
            favG = @favouritesGroupIdx
            if orientation is 0
                visibility = "landscape"
                groupInfo = [ calG, calG ]
                calDayIdx = [ 0, 1 ]
                colSpans = [ 2, 2 ]
                rowSpans = [ 2, 1 ]
            else
                visibility = "portrait"
                groupInfo = [ favG, calG, calG, calG ]
                calDayIdx = [ 0, 1, 2, 3]
                colSpans = [ 3, 3, 3, 3]
                rowSpans = [ 2, 2, 2, 1]
            for i in [0..groupInfo.length-1]
                groupIdx = groupInfo[i]
                colSpan = colSpans[i]
                rowSpan = rowSpans[i]
                if not (onlyAddToGroupIdx? and (onlyAddToGroupIdx isnt groupIdx))
                    tileBasics = new TileBasics @tileColours.getNextColour(), colSpan, rowSpan, null, "", "calendar", visibility, @tileTiers.getTileContainerSelector(tierIdx)
                    tile = new CalendarTile tileBasics, @calendarUrl, calDayIdx[i]
                    @tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile)

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

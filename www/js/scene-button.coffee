class App.SceneButton extends App.Tile
	constructor: (tileDef) ->
		super(tileDef)
		@buttonMarginX = 50
		@iconSize = [0,0]
		@fontPixels = 40
		@iconCellWidth = 80
		return

	addToDoc: (elemToAddTo) ->
		super(elemToAddTo)
		@contents.append """
			<div class="sqSceneButtonIcon" style="position:absolute"></div>
			<div class="sqSceneButtonText" style="position:absolute; font-size: #{@fontPixels}px;"></div>
			"""
		iconName = @tileDef.iconName
		if iconName is null
			iconName = ""
		@setIcon(iconName)
		@setText(@tileDef.tileText)
		return

	reposition: (@posX, @posY, @sizeX, @sizeY) ->
		super(@posX, @posY, @sizeX, @sizeY)
		iconSel = '#'+@tileId + " .sqSceneButtonIcon"
		textSel = '#'+@tileId + " .sqSceneButtonText"
		# Handle position with icon
		if @iconSize[0] isnt 0
			iconHeight = @sizeY / 2	
			iconWidth = iconHeight * @iconSize[0] / @iconSize[1]
			if @tileDef.iconX is "centre"
				iconX = (@sizeX-iconWidth)/2
				@setPositionCss(iconSel, iconX, (@sizeY-iconHeight)/2, iconWidth, iconHeight)
			else
				iconX = (@iconCellWidth - iconWidth)/2
				@setPositionCss(iconSel, iconX, (@sizeY-iconHeight)/2, iconWidth, iconHeight)
				txtHeight = $(textSel).height()
				textLeftX = @iconCellWidth
				@setPositionCss(textSel, textLeftX, (@sizeY-txtHeight)/2)
				txtWidth = $(textSel).width()
				txtCellWidth = @sizeX - textLeftX - @buttonMarginX
				if txtWidth > txtCellWidth
					fontScaling = txtCellWidth / txtWidth
					$(textSel).css
						fontSize: (fontScaling * @fontPixels) + "px"
				txtHeight = $(textSel).height()
				@setPositionCss(textSel, textLeftX, (@sizeY-txtHeight)/2)
		else
			# No icon so centre text
			txtHeight = $(textSel).height()
			$(textSel).css
				textAlign: "center"
			@setPositionCss(textSel, 0, (@sizeY-txtHeight)/2)
			txtWidth = $(textSel).width()
			txtCellWidth = @sizeX - @buttonMarginX*2
			if txtWidth > txtCellWidth
				fontScaling = txtCellWidth / txtWidth
				$(textSel).css
					fontSize: (fontScaling * @fontPixels) + "px"
			txtWidth = $(textSel).width()
			txtHeight = $(textSel).height()
			@setPositionCss(textSel, (@sizeX-txtWidth)/2, (@sizeY-txtHeight)/2)
		return

	setIcon: (iconName) ->
		if iconName is ""
			return
		iconUrl = 'img/' + iconName + '.png'
		$('#'+@tileId+" .sqSceneButtonIcon").html("<img src=#{iconUrl} style='height:100%'></img>")

		# Create new offscreen image get size from
		testImage = new Image()
		testImage.src = iconUrl
		@iconSize = [testImage.width, testImage.height]
		return

	setText: (@textStr) ->
		$('#'+@tileId+" .sqSceneButtonText").html @textStr
		return

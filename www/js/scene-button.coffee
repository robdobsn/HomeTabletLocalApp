class SceneButton extends Tile
	constructor: (tileDef) ->
		super tileDef
		return

	addToDoc: (elemToAddTo) ->
		super()
		@contents.append """
			<div class="sqSceneButtonIcon" style="position:absolute"></div>
			<div class="sqSceneButtonText" style="position:absolute"></div>
			"""
		iconName = @tileDef.iconName
		if iconName is null
			iconName = ""
		@setIcon(iconName)
		@setText(@tileDef.tileText)
		return

	reposition: (@posX, @posY, @sizeX, @sizeY, @fontScaling) ->
		super(posX, posY, sizeX, sizeY, fontScaling)
		iconSel = '#'+@tileId + " .sqSceneButtonIcon"
		iconHeight = @sizeY / 2
		iconWidth = iconHeight * @iconSize[0] / @iconSize[1]
		iconX = if @tileDef.iconX is "centre" then (@sizeX-iconWidth)/2 else @buttonMarginX
		@setPositionCss(iconSel, iconX, (@sizeY-iconHeight)/2, iconWidth, iconHeight)
		textSel = '#'+@tileId + " .sqSceneButtonText"
		txtHeight = $(textSel).height()
		@setPositionCss(textSel, iconX + @buttonMarginX + iconWidth, (@sizeY-txtHeight)/2, @sizeX-iconWidth-2*@buttonMarginX)
		return

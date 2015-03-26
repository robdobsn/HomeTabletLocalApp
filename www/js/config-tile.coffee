class ConfigTile extends Tile
	constructor: (tileDef, @configType) ->
		super tileDef
		return

	addToDoc: () ->
		super()
		@contents.append """
			<div class="sqSceneButtonIcon"><img src="img/config.png"></img></div>
			<div class="sqSceneButtonText"></div>
			"""
		iconName = "config"
		buttonText = ""
		if @configType is "tabname"
			buttonText = "Tablet Name"
		@setIcon(iconName)
		@setText(buttonText)
		return

	
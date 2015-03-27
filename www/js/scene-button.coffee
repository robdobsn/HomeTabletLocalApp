class SceneButton extends Tile
	constructor: (tileDef) ->
		super tileDef
		return

	addToDoc: (elemToAddTo) ->
		super()
		@contents.append """
			<div class="sqSceneButtonIcon"></div>
			<div class="sqSceneButtonText"></div>
			"""
		iconName = @tileDef.iconName
		if iconName is null
			iconName = ""
		 	# if @buttonText.toLowerCase().indexOf(" off") >= 0
		# 		iconName = "bulb-off"
		# 	else if @buttonText.toLowerCase().indexOf("nighttime") >= 0
		# 		iconName = "bulb-off"
		# 	else if @buttonText.toLowerCase().indexOf(" on") >= 0
		# 		iconName = "bulb-on"
		# 	else if @buttonText.toLowerCase().indexOf(" mood") >= 0
		# 		iconName = "bulb-mood"
		# 	else
		# 		iconName = "bulb-on"
		# @buttonText = @buttonText.replace(" Lights", "")
		# @buttonText = @buttonText.replace(" Light", "")
		@setIcon(iconName)
		@setText(@tileDef.tileText)
		return

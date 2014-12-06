class SceneButton extends Tile
	constructor: (tileBasics, @buttonText) ->
		super tileBasics

	addToDoc: (elemToAddTo) ->
		super()
		@contents.append """
			<div class="sqSceneButtonIcon"><img src="img/bulb-on.png"></img></div>
			<div class="sqSceneButtonText"></div>
			"""
		iconName = @tileBasics.iconName
		if iconName is null or iconName is ""
			if @buttonText.toLowerCase().indexOf("off") >= 0
				iconName = "bulb-off"
			else if @buttonText.toLowerCase().indexOf("nighttime") >= 0
				iconName = "bulb-off"
			else if @buttonText.toLowerCase().indexOf(" on") >= 0
				iconName = "bulb-on"
			else if @buttonText.toLowerCase().indexOf(" mood") >= 0
				iconName = "bulb-mood"
			else
				iconName = "bulb-on"
		@buttonText = @buttonText.replace(" Lights", "")
		@buttonText = @buttonText.replace(" Light", "")
		@setIcon(iconName)
		@setText(@buttonText)

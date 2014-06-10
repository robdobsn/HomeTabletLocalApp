class SceneButton extends Tile
	constructor: (tileBasics, @buttonText) ->
		super tileBasics

	addToDoc: (elemToAddTo) ->
		super()
		@contents.append """
			<div class="sqSceneButtonIcon"><img src="img/light-bulb-on.png"></img></div>
			<div class="sqSceneButtonText"></div>
			"""
		iconName = @tileBasics.iconName
		if iconName is null or iconName is ""
			if @buttonText.toLowerCase().indexOf("off") >= 0
				iconName = "bulb-off"
			else if @buttonText.toLowerCase().indexOf(" on") >= 0
				iconName = "bulb-on"
		@buttonText = @buttonText.replace(" Lights", "")
		@buttonText = @buttonText.replace(" Light", "")
		@setIcon(iconName)
		@setText(@buttonText)

	setIcon: (iconName) ->
		iconUrl = 'img/' + iconName + '.png'
		if iconName is 'bulb-on'
			iconUrl = 'img/light-bulb-on.png'
		else if iconName is 'bulb-off'
			iconUrl = 'img/light-bulb-off.png'
		else if iconName is 'shadesicon'
			iconUrl = 'img/shadesicon.png'
		else if iconName is 'musicicon'
			iconUrl = 'img/musicicon.png'
		if iconUrl isnt ""
			$('#'+@tileId+" .sqSceneButtonIcon img").attr("src", iconUrl)

	setText: (@textStr) ->
		$('#'+@tileId+" .sqSceneButtonText").html textStr

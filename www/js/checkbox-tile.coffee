class CheckBoxTile extends SceneButton
	constructor: (tileDef) ->
		super tileDef
		@stateVar = LocalStorage.get(tileDef.varName)
		return

	handleAction: (action) ->
		if action is "toggle"
			@stateVar = !@stateVar
			LocalStorage.set(@tileDef.varName, @stateVar)
		@setIcon()
		return

	setIcon: () ->
		if @stateVar is true
			super(@tileDef.iconName)
		else
			super(@tileDef.iconNameOff)
		return


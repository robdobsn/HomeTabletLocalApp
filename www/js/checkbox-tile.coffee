class App.CheckBoxTile extends App.SceneButton
	constructor: (tileDef) ->
		super tileDef
		@stateVar = App.LocalStorage.get(tileDef.varName)
		return

	handleAction: (action) ->
		if action is "toggle"
			@stateVar = !@stateVar
			App.LocalStorage.set(@tileDef.varName, @stateVar)
		@setIcon()
		return

	setIcon: () ->
		if @stateVar is true
			super(@tileDef.iconName)
		else
			super(@tileDef.iconNameOff)
		return


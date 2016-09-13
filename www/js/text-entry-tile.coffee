class App.TextEntryTile extends App.Tile
	constructor: (tileDef) ->
		super(tileDef)
		@fontPixels = 30
		@leftMarginX = 10
		@stateVar = App.LocalStorage.get(tileDef.varName)
		return 

	addToDoc: (elemToAddTo) ->
		super(elemToAddTo)
		@contents.append """
			<span class="sqTextEntryLabel" style="position:relative"></span>
			<span><input class="sqTextEntryInput" style="position:relative; 
				font-size: #{@fontPixels}px; type="text""></input></span>
			"""
		inputSel = '#'+@tileId + " .sqTextEntryInput"
		$(inputSel).bind 'input', =>
			App.LocalStorage.set(@tileDef.varName, $(inputSel).val())
		return

	reposition: (@posX, @posY, @sizeX, @sizeY) ->
		super(@posX, @posY, @sizeX, @sizeY)
		labelSel = '#'+@tileId + " .sqTextEntryLabel"
		inputSel = '#'+@tileId + " .sqTextEntryInput"
		$(labelSel).text(@tileDef.label)
		$(inputSel).val(@stateVar)
		$(labelSel).css
			fontSize: @fontPixels + "px"
		$(inputSel).css
			fontSize: @fontPixels + "px"
		txtHeight = $(inputSel).height()
		@setPositionCss(labelSel, @leftMarginX, (@sizeY-txtHeight)/2)
		lblWidth = $(labelSel).width()
		@setPositionCss(inputSel, null, (@sizeY-txtHeight)/2, @sizeX - lblWidth - 4*@leftMarginX)
		return

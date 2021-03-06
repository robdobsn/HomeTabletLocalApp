class App.TilePosition
	constructor: (@tileValid, @xPos = 0, @yPos = 0, @colSpan = 0, @rowSpan = 0) ->
		return
		
	intersects: (tilePos) ->
		if not @tileValid
			return false
		if @xPos > tilePos.xPos + tilePos.colSpan - 1
			return false
		if @xPos + @colSpan - 1 < tilePos.xPos
			return false
		if @yPos > tilePos.yPos + tilePos.rowSpan - 1
			return false
		if @yPos + @rowSpan - 1 < tilePos.yPos
			return false
		return true

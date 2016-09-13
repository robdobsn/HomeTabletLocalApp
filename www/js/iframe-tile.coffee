class App.IframeTile extends App.Tile
	constructor: (tileDef) ->
		super tileDef
		@iframeSource = tileDef.contentUrl
		return

	addToDoc: (elemToAddTo) ->
		super()
		@contents.append """
			<div class="sqIframeTile"
				style="height:100%;margin:0px;padding:0px;overflow:hidden">
				<iframe src=#{@iframeSource}
				   frameborder="0" 
				   style="overflow:hidden"
				   height="100%" 
				   width="100%">
				</iframe></div>
			"""
		return

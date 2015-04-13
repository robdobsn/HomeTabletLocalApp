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

	       #  <div id="tabnameform" style="display:none;">
        #     <p>Tablet name</p>
        #     <div class="formField">
        #     Name: <input id="tabnamefield" name="tabnamefield" placeholder="Tablet Name" type="text">
        #     </div>
        #     <button id="tabnameok" 
        #             href="javascript:void(0);" 
        #             style="display:block; opacity:1;">
        #         Ok
        #     </button>
        # </div>
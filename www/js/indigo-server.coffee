class IndigoServer
	constructor: (@serverURL) ->
		@ACTIONS_URI = @serverURL + "/actions.xml"

	setReadyCallback: (@indigoReadyCallback) ->

	getActionGroups: ->
		matchRe = ///
			<action\b[^>]href="(.*?).xml"[^>]*>(.*?)</action>
			///
		$.ajax @ACTIONS_URI,
			type: "GET"
			dataType: "xml"
			crossDomain: true
			success: (data, textStatus, jqXHR) =>
				bLoop = true
				respText = jqXHR.responseText
				actions = []
				while bLoop
					action = matchRe.exec(respText)
					if action is null then break
					pos = respText.search matchRe
					if pos is -1 then break
					respText = respText.substring(pos+action[0].length)
					actionDict = { actionNum: "", actionName: action[2], groupName: "", actionUrl: @serverURL + action[1] + "?_method=execute" }
					actions[actions.length] = actionDict				
				@indigoReadyCallback(actions)

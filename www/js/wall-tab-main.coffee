
$(document).bind ("mobileinit"), ->
	# This isn't currently needed as the tablet now uses a local server
	$.mobile.allowCrossDomainPages = true
	$.support.cors = true

$(document).ready ->
	FastClick.attach(document.body)
	wallTabApp = new WallTabApp()
	wallTabApp.go()

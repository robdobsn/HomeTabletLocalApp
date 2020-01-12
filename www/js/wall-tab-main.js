(function() {
  window.App = {};

  $(document).bind("mobileinit", function() {
    // This isn't currently needed as the tablet now uses a local server
    $.mobile.allowCrossDomainPages = true;
    return $.support.cors = true;
  });

  $(document).ready(function() {
    var wallTabApp;
    FastClick.attach(document.body);
    wallTabApp = new App.WallTabApp();
    return wallTabApp.go();
  });

}).call(this);


//# sourceMappingURL=wall-tab-main.js.map
//# sourceURL=coffeescript
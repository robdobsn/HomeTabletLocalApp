// Generated by CoffeeScript 1.6.3
var IndigoServer;

IndigoServer = (function() {
  function IndigoServer(serverURL) {
    this.serverURL = serverURL;
    this.ACTIONS_URI = this.serverURL + "/actions.xml";
  }

  IndigoServer.prototype.setReadyCallback = function(indigoReadyCallback) {
    this.indigoReadyCallback = indigoReadyCallback;
  };

  IndigoServer.prototype.getActionGroups = function() {
    var matchRe,
      _this = this;
    matchRe = /<action\b[^>]href="(.*?).xml"[^>]*>(.*?)<\/action>/;
    return $.ajax(this.ACTIONS_URI, {
      type: "GET",
      dataType: "xml",
      crossDomain: true,
      success: function(data, textStatus, jqXHR) {
        var action, actions, bLoop, pos, respText;
        bLoop = true;
        respText = jqXHR.responseText;
        actions = [];
        while (bLoop) {
          action = matchRe.exec(respText);
          if (action === null) {
            break;
          }
          pos = respText.search(matchRe);
          if (pos === -1) {
            break;
          }
          respText = respText.substring(pos + action[0].length);
          actions[actions.length] = new Array("", action[2], "", _this.serverURL + action[1] + "?_method=execute");
        }
        return _this.indigoReadyCallback(actions);
      }
    });
  };

  return IndigoServer;

})();

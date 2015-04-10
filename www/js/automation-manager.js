// Generated by CoffeeScript 1.8.0
var AutomationManager,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

AutomationManager = (function() {
  function AutomationManager(app, readyCallback) {
    this.app = app;
    this.readyCallback = readyCallback;
    this.executeCommand = __bind(this.executeCommand, this);
    this.actionsReadyCb = __bind(this.actionsReadyCb, this);
    this.serverDefs = [];
    this.servers = [];
    this.sumActions = {};
    this.iconAliasing = {};
  }

  AutomationManager.prototype.setReadyCallback = function(readyCallback) {
    this.readyCallback = readyCallback;
  };

  AutomationManager.prototype.requestUpdate = function(configData) {
    var dataChanged, idx, server, serverDef, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    this.iconAliasing = "iconAliasing" in configData.common ? configData.common.iconAliasing : {};
    if ("fixedActions" in configData.common) {
      this.sumActions["fixedActions"] = configData.common.fixedActions;
    } else {
      this.sumActions["fixedActions"] = null;
    }
    if (!("servers" in configData.common)) {
      return;
    }
    dataChanged = false;
    if (this.servers.length === configData.common.servers.length) {
      _ref = configData.common.servers;
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        serverDef = _ref[idx];
        if (this.serverDefs[idx].type !== serverDef.type) {
          dataChanged = true;
        }
        if (this.serverDefs[idx].name !== serverDef.name) {
          dataChanged = true;
        }
        if (this.serverDefs[idx].url !== serverDef.url) {
          dataChanged = true;
        }
      }
    } else {
      dataChanged = true;
    }
    if (dataChanged) {
      this.servers = [];
      _ref1 = configData.common.servers;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        serverDef = _ref1[_j];
        if (serverDef.type === "indigo") {
          this.servers.push(new IndigoServer(this, serverDef, this.actionsReadyCb));
        } else if (serverDef.type === "indigo-test") {
          this.servers.push(new IndigoTestServer(this, serverDef, this.actionsReadyCb));
        } else if (serverDef.type === "vera") {
          this.servers.push(new VeraServer(this, serverDef, this.actionsReadyCb));
        } else if (serverDef.type === "fibaro") {
          this.servers.push(new FibaroServer(this, serverDef, this.actionsReadyCb));
        }
      }
    }
    _ref2 = this.servers;
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      server = _ref2[_k];
      server.reqActions();
    }
    this.readyCallback(true);
  };

  AutomationManager.prototype.actionsReadyCb = function(serverName, actions) {
    this.sumActions[serverName] = actions;
    this.readyCallback(true);
  };

  AutomationManager.prototype.getActionGroups = function() {
    return this.sumActions;
  };

  AutomationManager.prototype.executeCommand = function(cmdParams) {
    if ((cmdParams == null) || cmdParams === "") {
      return;
    }
    return $.ajax(cmdParams, {
      type: "GET",
      dataType: "text",
      success: (function(_this) {
        return function(data, textStatus, jqXHR) {
          _this.app.mediaPlayHelper.play("ok");
        };
      })(this),
      error: (function(_this) {
        return function(jqXHR, textStatus, errorThrown) {
          console.error("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmdParams);
          _this.app.mediaPlayHelper.play("fail");
        };
      })(this)
    });
  };

  AutomationManager.prototype.getIconFromActionName = function(actionName, aliasingGroup) {
    var aliasDef, aliases, _i, _len;
    if (aliasingGroup == null) {
      return "";
    }
    if (!(aliasingGroup in this.iconAliasing)) {
      return "";
    }
    aliases = this.iconAliasing[aliasingGroup];
    for (_i = 0, _len = aliases.length; _i < _len; _i++) {
      aliasDef = aliases[_i];
      if (actionName.match(aliasDef.regex)) {
        return aliasDef.iconName;
      }
    }
    return "";
  };

  return AutomationManager;

})();
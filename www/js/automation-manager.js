// Generated by CoffeeScript 1.10.0
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  App.AutomationManager = (function() {
    function AutomationManager(app, readyCallback) {
      this.app = app;
      this.readyCallback = readyCallback;
      this.executeCommand = bind(this.executeCommand, this);
      this.actionsReadyCb = bind(this.actionsReadyCb, this);
      this.serverDefs = [];
      this.servers = [];
      this.sumActions = {};
      this.iconAliasing = {};
      this.combinedActions = {};
    }

    AutomationManager.prototype.setReadyCallback = function(readyCallback) {
      this.readyCallback = readyCallback;
    };

    AutomationManager.prototype.requestUpdate = function(configData) {
      var dataChanged, i, idx, j, k, len, len1, len2, ref, ref1, ref2, server, serverDef;
      this.iconAliasing = "iconAliasing" in configData.common ? configData.common.iconAliasing : {};
      if ("fixedActions" in configData.common) {
        this.sumActions["fixedActions"] = configData.common.fixedActions;
      } else {
        this.sumActions["fixedActions"] = null;
      }
      if ("servers" in configData.common) {
        dataChanged = false;
        if (this.serverDefs.length === configData.common.servers.length) {
          ref = configData.common.servers;
          for (idx = i = 0, len = ref.length; i < len; idx = ++i) {
            serverDef = ref[idx];
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
          ref1 = configData.common.servers;
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            serverDef = ref1[j];
            if (serverDef.type === "indigo" || serverDef.type === "Indigo") {
              this.servers.push(new App.IndigoServer(this, serverDef, this.actionsReadyCb));
            } else if (serverDef.type === "indigo-test") {
              this.servers.push(new App.IndigoTestServer(this, serverDef, this.actionsReadyCb));
            } else if (serverDef.type === "vera" || serverDef.type === "Vera") {
              this.servers.push(new App.VeraServer(this, serverDef, this.actionsReadyCb));
            } else if (serverDef.type === "fibaro" || serverDef.type === "Fibaro") {
              this.servers.push(new App.FibaroServer(this, serverDef, this.actionsReadyCb));
            }
            if (serverDef.type === "domoticz" || serverDef.type === "Domoticz") {
              this.servers.push(new App.DomoticzServer(this, serverDef, this.actionsReadyCb));
            }
          }
        }
      } else {
        this.servers = [];
      }
      this.serverDefs = configData.common.servers;
      ref2 = this.servers;
      for (k = 0, len2 = ref2.length; k < len2; k++) {
        server = ref2[k];
        server.reqActions();
      }
      this.readyCallback(true);
    };

    AutomationManager.prototype.actionsReadyCb = function(serverName, actions) {
      var dataChanged;
      dataChanged = true;
      if (serverName in this.sumActions) {
        dataChanged = JSON.stringify(this.sumActions[serverName]) !== actions;
      }
      if (dataChanged) {
        this.sumActions[serverName] = actions;
      }
      this.combinedActions["actions"] = this.generateCombinedActions();
      this.readyCallback(dataChanged);
    };

    AutomationManager.prototype.getActionGroups = function() {
      return this.combinedActions;
    };

    AutomationManager.prototype.generateCombinedActions = function() {
      var dupFound, duplicatedActions, i, j, key, len, len1, mergedActionsList, otherServerAction, otherServerActions, otherServerName, ref, ref1, serverAction, serverActions, serverName, val;
      mergedActionsList = [];
      duplicatedActions = {};
      ref = this.sumActions;
      for (serverName in ref) {
        serverActions = ref[serverName];
        for (i = 0, len = serverActions.length; i < len; i++) {
          serverAction = serverActions[i];
          dupFound = false;
          ref1 = this.sumActions;
          for (otherServerName in ref1) {
            otherServerActions = ref1[otherServerName];
            if (otherServerName === serverName) {
              continue;
            }
            for (j = 0, len1 = otherServerActions.length; j < len1; j++) {
              otherServerAction = otherServerActions[j];
              if (otherServerAction.actionName === serverAction.actionName && (((otherServerAction.groupName == null) && (serverAction.groupName == null)) || (otherServerAction.groupName === serverAction.groupName))) {
                if (serverAction.actionName in duplicatedActions) {
                  duplicatedActions[serverAction.actionName].actionUrl += ";" + serverAction.actionUrl;
                } else {
                  duplicatedActions[serverAction.actionName] = serverAction;
                }
                dupFound = true;
                break;
              }
            }
            if (dupFound) {
              break;
            }
          }
          if (!dupFound) {
            mergedActionsList.push(serverAction);
          }
        }
      }
      for (key in duplicatedActions) {
        val = duplicatedActions[key];
        mergedActionsList.push(val);
      }
      return mergedActionsList;
    };

    AutomationManager.prototype.soundResult = function(cmdsToDo, cmdsCompleted, cmdsFailed) {
      if (cmdsCompleted === cmdsToDo) {
        if (cmdsFailed === 0) {
          this.app.mediaPlayHelper.play("ok");
        } else {
          this.app.mediaPlayHelper.play("fail");
        }
      }
    };

    AutomationManager.prototype.executeCommand = function(cmdParams) {
      var cmd, cmdParts, cmds, cmdsCompleted, cmdsFailed, cmdsToDo, i, len;
      if ((cmdParams == null) || cmdParams === "") {
        return;
      }
      cmds = cmdParams.split(";");
      this.app.mediaPlayHelper.play("click");
      cmdsCompleted = 0;
      cmdsFailed = 0;
      cmdsToDo = cmds.length;
      for (i = 0, len = cmds.length; i < len; i++) {
        cmd = cmds[i];
        if (cmd.indexOf("~POST~")) {
          cmdParts = cmd.split("~");
          $.ajax(cmdParts[0], {
            type: "POST",
            dataType: "text",
            data: cmdParts[2],
            success: (function(_this) {
              return function(data, textStatus, jqXHR) {
                cmdsCompleted++;
                _this.soundResult(cmdsToDo, cmdsCompleted, cmdsFailed);
              };
            })(this),
            error: (function(_this) {
              return function(jqXHR, textStatus, errorThrown) {
                console.error("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmd);
                cmdsFailed++;
                cmdsCompleted++;
              };
            })(this)
          });
        } else {
          console.log("Exec command " + cmd);
          $.ajax(cmd, {
            type: "GET",
            dataType: "text",
            success: (function(_this) {
              return function(data, textStatus, jqXHR) {
                cmdsCompleted++;
                _this.soundResult(cmdsToDo, cmdsCompleted, cmdsFailed);
              };
            })(this),
            error: (function(_this) {
              return function(jqXHR, textStatus, errorThrown) {
                console.error("Direct exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmd);
                cmdsFailed++;
                cmdsCompleted++;
              };
            })(this)
          });
        }
      }
    };

    AutomationManager.prototype.getIconFromActionName = function(actionName, aliasingGroup) {
      var aliasDef, aliases, i, len;
      if (aliasingGroup == null) {
        return "";
      }
      if (!(aliasingGroup in this.iconAliasing)) {
        return "";
      }
      aliases = this.iconAliasing[aliasingGroup];
      for (i = 0, len = aliases.length; i < len; i++) {
        aliasDef = aliases[i];
        if (actionName.match(aliasDef.regex)) {
          return aliasDef.iconName;
        }
      }
      return "";
    };

    return AutomationManager;

  })();

}).call(this);

//# sourceMappingURL=automation-manager.js.map

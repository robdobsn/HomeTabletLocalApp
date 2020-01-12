(function() {
  App.AutomationManager = class AutomationManager {
    constructor(app, readyCallback) {
      this.actionsReadyCb = this.actionsReadyCb.bind(this);
      this.executeCommand = this.executeCommand.bind(this);
      this.app = app;
      this.readyCallback = readyCallback;
      this.serverDefs = [];
      this.servers = [];
      this.sumActions = {};
      this.iconAliasing = {};
      this.combinedActions = {};
    }

    setReadyCallback(readyCallback) {
      this.readyCallback = readyCallback;
    }

    requestUpdate(configData) {
      var dataChanged, i, idx, j, k, len, len1, len2, ref, ref1, ref2, server, serverDef;
      // Stash icon aliasing info
      this.iconAliasing = "iconAliasing" in configData.common ? configData.common.iconAliasing : {};
      // Get actions from config data
      if ("fixedActions" in configData.common) {
        this.sumActions["fixedActions"] = configData.common.fixedActions;
      } else {
        this.sumActions["fixedActions"] = null;
      }
      // Check if server list has changed
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
        // If changed then create servers
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
            } else if (serverDef.type === "domoticz" || serverDef.type === "Domoticz") {
              this.servers.push(new App.DomoticzServer(this, serverDef, this.actionsReadyCb));
            } else if (serverDef.type === "robhome" || serverDef.type === "RobHome") {
              this.servers.push(new App.RobHomeServer(this, serverDef, this.actionsReadyCb));
            }
          }
        }
      } else {
        this.servers = [];
      }
      this.serverDefs = configData.common.servers;
      ref2 = this.servers;
      // Request data from servers
      for (k = 0, len2 = ref2.length; k < len2; k++) {
        server = ref2[k];
        server.reqActions();
      }
      // Callback now with initial actions (fixed actions)
      this.readyCallback(true);
    }

    actionsReadyCb(serverName, actions) {
      var dataChanged;
      // Check if the data for this action has changed
      dataChanged = true;
      if (serverName in this.sumActions) {
        dataChanged = JSON.stringify(this.sumActions[serverName]) !== actions;
      }
      if (dataChanged) {
        this.sumActions[serverName] = actions;
      }
      // Process the data further to remove duplications (two servers might have the same action)
      // and convert these duplicates into separate action maintained by this object
      this.combinedActions["actions"] = this.generateCombinedActions();
      this.readyCallback(dataChanged);
    }

    getActionGroups() {
      return this.combinedActions;
    }

    generateCombinedActions() {
      var dupFound, duplicatedActions, i, j, key, len, len1, mergedActionsList, otherServerAction, otherServerActions, otherServerName, ref, ref1, serverAction, serverActions, serverName, val;
      // Flatten all sources into an actions list
      mergedActionsList = [];
      duplicatedActions = {};
      ref = this.sumActions;
      // Go through the actions of each server
      for (serverName in ref) {
        serverActions = ref[serverName];
        for (i = 0, len = serverActions.length; i < len; i++) {
          serverAction = serverActions[i];
          dupFound = false;
          ref1 = this.sumActions;
          // Check against other server's actions
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
        console.error("MergedAction " + val.actionUrl);
      }
      return mergedActionsList;
    }

    soundResult(cmdsToDo, cmdsCompleted, cmdsFailed) {
      if (cmdsCompleted === cmdsToDo) {
        if (cmdsFailed === 0) {
          this.app.mediaPlayHelper.play("ok");
        } else {
          this.app.mediaPlayHelper.play("fail");
        }
      }
    }

    executeCommand(cmdParams) {
      var cmd, cmdParts, cmds, cmdsCompleted, cmdsFailed, cmdsToDo, i, len;
      if ((cmdParams == null) || cmdParams === "") {
        return;
      }
      // Commands can be ; separated
      cmds = cmdParams.split(";");
      this.app.mediaPlayHelper.play("click");
      cmdsCompleted = 0;
      cmdsFailed = 0;
      cmdsToDo = cmds.length;
      for (i = 0, len = cmds.length; i < len; i++) {
        cmd = cmds[i];
        // Check if command contains "~POST~" - to indicate POST rather than GET
        if (cmd.indexOf("~POST~") > 0) {
          console.log("WallTabletDebug Exec POST command " + cmd);
          cmdParts = cmd.split("~");
          $.ajax(cmdParts[0], {
            type: "POST",
            dataType: "text",
            data: cmdParts[2],
            success: (data, textStatus, jqXHR) => {
              cmdsCompleted++;
              this.soundResult(cmdsToDo, cmdsCompleted, cmdsFailed);
            },
            error: (jqXHR, textStatus, errorThrown) => {
              console.error("WallTabletDebug POST exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmd);
              cmdsFailed++;
              cmdsCompleted++;
            }
          });
        } else {
          console.log("WallTabletDebug Exec GET command " + cmd);
          $.ajax(cmd, {
            type: "GET",
            dataType: "text",
            success: (data, textStatus, jqXHR) => {
              cmdsCompleted++;
              this.soundResult(cmdsToDo, cmdsCompleted, cmdsFailed);
            },
            error: (jqXHR, textStatus, errorThrown) => {
              console.error("WallTabletDebug GET exec command failed: " + textStatus + " " + errorThrown + " COMMAND=" + cmd);
              cmdsFailed++;
              cmdsCompleted++;
            }
          });
        }
      }
    }

    getIconFromActionName(actionName, aliasingGroup) {
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
    }

  };

}).call(this);


//# sourceMappingURL=automation-manager.js.map
//# sourceURL=coffeescript
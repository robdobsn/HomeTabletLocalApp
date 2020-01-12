(function() {
  App.IndigoServer = class IndigoServer {
    constructor(manager, serverDef, dataReadyCallback) {
      this.manager = manager;
      this.serverDef = serverDef;
      this.dataReadyCallback = dataReadyCallback;
      this.ACTIONS_URI = this.serverDef.url + "/actions.json";
      this.numRefreshFailuresSinceSuccess = 0;
      this.firstRefreshAfterFailSecs = 10;
      this.nextRefreshesAfterFailSecs = 60;
      return;
    }

    setReadyCallback(dataReadyCallback) {
      this.dataReadyCallback = dataReadyCallback;
    }

    reqActions() {
      console.log("Requesting Indigo data from " + this.ACTIONS_URI);
      $.ajax(this.ACTIONS_URI, {
        type: "GET",
        dataType: "json",
        crossDomain: true,
        success: (data, textStatus, jqXHR) => {
          this.processRecvdActions(data);
          // console.log "Indigo data = " + JSON.stringify(@scenes)
          console.log("Received Indigo data from " + this.ACTIONS_URI);
          this.numRefreshFailuresSinceSuccess = 0;
          App.LocalStorage.set(this.ACTIONS_URI, data);
        },
        error: (jqXHR, textStatus, errorThrown) => {
          var storedData;
          App.LocalStorage.logEvent("IndLog", "AjaxFail Status= " + textStatus + " URL= " + this.ACTIONS_URI + " Error= " + errorThrown);
          this.numRefreshFailuresSinceSuccess++;
          setTimeout(() => {
            return this.getActionGroups;
          }, (this.numRefreshFailuresSinceSuccess === 1 ? this.firstRefreshAfterFailSecs * 1000 : this.nextRefreshesAfterFailSecs * 1000));
          // Use stored data if available
          storedData = App.LocalStorage.get(this.ACTIONS_URI);
          // console.log "Getting data stored for " + @ACTIONS_URI + " result = " + storedData
          if (storedData != null) {
            // console.log "Using stored data" + JSON.stringify(storedData)
            console.log("Using stored data for " + this.ACTIONS_URI);
            this.processRecvdActions(storedData);
          }
        }
      });
    }

    processRecvdActions(data) {
      this.scenes = this.getScenes(data);
      this.scenes.sort(this.sortByRoomName);
      return this.dataReadyCallback(this.serverDef.name, this.scenes);
    }

    sortByRoomName(a, b) {
      if (a.groupName < b.groupName) {
        return -1;
      }
      if (a.groupName > b.groupName) {
        return 1;
      }
      return 0;
    }

    getScenes(data, rooms) {
      var actionName, i, indigoScene, indigoScenes, len, name, roomName, scene, scenes;
      indigoScenes = data;
      scenes = [];
      for (i = 0, len = indigoScenes.length; i < len; i++) {
        indigoScene = indigoScenes[i];
        name = indigoScene.name.split(" - ");
        actionName = indigoScene.name;
        if (name.length > 1) {
          roomName = name[0].trim();
          actionName = name[1].trim();
        }
        scene = {
          actionNum: "",
          actionName: roomName + " " + actionName,
          groupName: roomName,
          actionUrl: this.serverDef.url + "/actions/" + indigoScene.nameURLEncoded + "?_method=execute",
          iconName: this.manager.getIconFromActionName(actionName, this.serverDef.iconAliasing)
        };
        scenes.push(scene);
      }
      return scenes;
    }

    getActionGroupsXML() {
      var matchRe;
      matchRe = /<action\b[^>]href="(.*?).xml"[^>]*>(.*?)<\/action>/;
      $.ajax(this.ACTIONS_URI, {
        type: "GET",
        dataType: "xml",
        crossDomain: true,
        success: (data, textStatus, jqXHR) => {
          var action, actionDict, actions, bLoop, pos, respText;
          bLoop = true;
          respText = jqXHR.responseText;
          actions = [];
          console.log("Got from Indigo " + jqXHR.responseText);
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
            actionDict = {
              actionNum: "",
              actionName: action[2],
              groupName: "",
              actionUrl: this.serverDef.url + action[1] + "?_method=execute"
            };
            actions[actions.length] = actionDict;
            console.log("Adding action " + JSON.stringify(actionDict));
          }
          return this.dataReadyCallback(this.serverDef.name, actions);
        }
      });
    }

  };

}).call(this);


//# sourceMappingURL=indigo-server.js.map
//# sourceURL=coffeescript
// Generated by CoffeeScript 2.5.1
(function() {
  App.DomoticzServer = class DomoticzServer {
    constructor(manager, serverDef, dataReadyCallback) {
      this.manager = manager;
      this.serverDef = serverDef;
      this.dataReadyCallback = dataReadyCallback;
      this.ACTIONS_URI = this.serverDef.url + "/json.htm?type=scenes";
      this.numRefreshFailuresSinceSuccess = 0;
      this.firstRefreshAfterFailSecs = 10;
      this.nextRefreshesAfterFailSecs = 60;
      return;
    }

    setReadyCallback(dataReadyCallback) {
      this.dataReadyCallback = dataReadyCallback;
    }

    reqActions() {
      console.log("domiticz-server Requesting Domoticz data from " + this.ACTIONS_URI);
      $.ajax(this.ACTIONS_URI, {
        type: "GET",
        dataType: "json",
        crossDomain: true,
        success: (data, textStatus, jqXHR) => {
          this.processRecvdActions(data);
          // console.log "Domoticz data = " + JSON.stringify(@scenes)
          console.log("domiticz-server Received Domoticz data from " + this.ACTIONS_URI);
          this.numRefreshFailuresSinceSuccess = 0;
          App.LocalStorage.set(this.ACTIONS_URI, data);
        },
        error: (jqXHR, textStatus, errorThrown) => {
          var storedData;
          console.log("domiticz-server " + " DOMOTICZ AjaxFail Status= " + textStatus + " URL= " + this.ACTIONS_URI + " Error= " + errorThrown);
          App.LocalStorage.logEvent("DomLog", "AjaxFail Status= " + textStatus + " URL= " + this.ACTIONS_URI + " Error= " + errorThrown);
          this.numRefreshFailuresSinceSuccess++;
          setTimeout(() => {
            return this.getActionGroups;
          }, (this.numRefreshFailuresSinceSuccess === 1 ? this.firstRefreshAfterFailSecs * 1000 : this.nextRefreshesAfterFailSecs * 1000));
          // Use stored data if available
          storedData = App.LocalStorage.get(this.ACTIONS_URI);
          console.log("domiticz-server Getting data stored for " + this.ACTIONS_URI + " result = " + storedData);
          if (storedData != null) {
            // console.log "Using stored data" + JSON.stringify(storedData)
            console.log("domiticz-server Using stored data for " + this.ACTIONS_URI);
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
      var actionName, i, len, name, roomName, scene, scenes, serverScene, serverScenes;
      serverScenes = data.result;
      scenes = [];
      if (serverScenes != null) {
        for (i = 0, len = serverScenes.length; i < len; i++) {
          serverScene = serverScenes[i];
          name = serverScene.Name.split(" - ");
          actionName = serverScene.Name;
          if (name.length > 1) {
            roomName = name[0].trim();
            actionName = name[1].trim();
          }
          scene = {
            actionNum: "",
            actionName: roomName + " " + actionName,
            groupName: roomName,
            actionUrl: this.serverDef.url + "/json.htm?type=command&param=switchscene&idx=" + serverScene.idx + "&switchcmd=On",
            iconName: this.manager.getIconFromActionName(actionName, this.serverDef.iconAliasing)
          };
          scenes.push(scene);
        }
      }
      return scenes;
    }

  };

}).call(this);

//# sourceMappingURL=domoticz-server.js.map

(function() {
  App.RobHomeServer = class RobHomeServer {
    constructor(manager, serverDef, dataReadyCallback) {
      this.manager = manager;
      this.serverDef = serverDef;
      this.dataReadyCallback = dataReadyCallback;
      this.ACTIONS_URI = this.serverDef.url + "/mainconfig";
      this.numRefreshFailuresSinceSuccess = 0;
      this.firstRefreshAfterFailSecs = 10;
      this.nextRefreshesAfterFailSecs = 60;
      return;
    }

    setReadyCallback(dataReadyCallback) {
      this.dataReadyCallback = dataReadyCallback;
    }

    reqActions() {
      console.log("WallTabletDebug Requesting RobHomeServer data from " + this.ACTIONS_URI);
      $.ajax(this.ACTIONS_URI, {
        type: "GET",
        dataType: "json",
        crossDomain: true,
        success: (data, textStatus, jqXHR) => {
          this.processRecvdActions(data);
          // console.log "RobHomeServer data = " + JSON.stringify(@scenes)
          console.log("WallTabletDebug Received RobHomeServer data from " + this.ACTIONS_URI);
          this.numRefreshFailuresSinceSuccess = 0;
          App.LocalStorage.set(this.ACTIONS_URI, data);
        },
        error: (jqXHR, textStatus, errorThrown) => {
          var storedData;
          console.log("WallTabletDebug " + " RobHomeServer AjaxFail Status= " + textStatus + " URL= " + this.ACTIONS_URI + " Error= " + errorThrown);
          App.LocalStorage.logEvent("RobLog", "AjaxFail Status= " + textStatus + " URL= " + this.ACTIONS_URI + " Error= " + errorThrown);
          this.numRefreshFailuresSinceSuccess++;
          setTimeout(() => {
            return this.getActionGroups;
          }, (this.numRefreshFailuresSinceSuccess === 1 ? this.firstRefreshAfterFailSecs * 1000 : this.nextRefreshesAfterFailSecs * 1000));
          // Use stored data if available
          storedData = App.LocalStorage.get(this.ACTIONS_URI);
          console.log("WallTabletDebug Getting data stored for " + this.ACTIONS_URI + " result = " + storedData);
          if (storedData != null) {
            // console.log "Using stored data" + JSON.stringify(storedData)
            console.log("WallTabletDebug Using stored data for " + this.ACTIONS_URI);
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
      var actionName, i, len, scene, scenes, serverScene, serverScenes;
      scenes = [];
      serverScenes = data.scenes;
      console.log("RobHomeServer data = " + JSON.stringify(serverScenes));
      if (serverScenes != null) {
        for (i = 0, len = serverScenes.length; i < len; i++) {
          serverScene = serverScenes[i];
          actionName = serverScene.room + " - " + serverScene.nom;
          scene = {
            actionNum: "",
            actionName: serverScene.room + " " + serverScene.nom,
            groupName: serverScene.room,
            actionUrl: serverScene.urls.join(";"),
            iconName: this.manager.getIconFromActionName(actionName, this.serverDef.iconAliasing)
          };
          scenes.push(scene);
          console.log("RobHomeServer scene " + JSON.stringify(scene));
        }
      }
      return scenes;
    }

  };

}).call(this);


//# sourceMappingURL=robhome-server.js.map
//# sourceURL=coffeescript
(function() {
  App.FibaroServer = class FibaroServer {
    constructor(manager, serverDef, dataReadyCallback) {
      this.manager = manager;
      this.serverDef = serverDef;
      this.dataReadyCallback = dataReadyCallback;
      this.ROOMS_URL = this.serverDef.url + "/api/rooms";
      this.SCENES_URL = this.serverDef.url + "/api/scenes";
      return;
    }

    setReadyCallback(dataReadyCallback) {
      this.dataReadyCallback = dataReadyCallback;
    }

    reqActions() {
      // xmlhttp = new XMLHttpRequest()
      // xmlhttp.onreadystatechange = () =>
      // 	if xmlhttp.readyState == 4
      // 		if xmlhttp.status == 200
      // 			alert "Resp " + xmlhttp.responseText
      // 		else if xmlhttp.status == 400
      // 			alert 'There was an error 400'
      // 		else
      // 			alert 'Other error ' + xmlhttp.status
      // 	else
      // 		alert('something else other than 200 was returned')
      // xmlhttp.open("GET", @ROOMS_URL, true)
      // xmlhttp.setRequestHeader('Content-type', 'application/json')
      // xmlhttp.setRequestHeader("Authorization", "Basic " + btoa("admin" + ":" + "b6107430"))
      // xmlhttp.send()

      // return
      console.log("Get from Fibaro " + this.ROOMS_URL);
      $.ajax(this.ROOMS_URL, {
        type: "GET",
        dataType: "json",
        // contentType: 'application/text'
        crossDomain: true,
        // headers: "Authorization": "Basic " + btoa("admin" + ":" + "b6107430")
        // beforeSend: (xhr) =>
        //     xhr.setRequestHeader("Authorization", @makeBasicAuth("admin", "b6107430"))
        error: (jqXHR, textStatus, errorThrown) => {
          console.log("Fibaro Rooms failed: " + textStatus + " " + errorThrown);
        },
        success: (data, textStatus, jqXHR) => {
          console.log("Got from Fibaro");
          this.rooms = data;
          $.ajax(this.SCENES_URL, {
            type: "GET",
            dataType: "json",
            crossDomain: true,
            success: (data, textStatus, jqXHR) => {
              this.scenes = this.getScenes(data, this.rooms);
              this.scenes.sort(this.sortByRoomName);
              this.dataReadyCallback(this.serverDef.name, this.scenes);
              console.log("Fibaro data = " + JSON.stringify(this.scenes));
            }
          });
        }
      });
    }

    makeBasicAuth(username, password) {
      var hash, tok;
      tok = username + ':' + password;
      hash = btoa(tok);
      return 'Basic ' + hash;
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
      var fibaroScene, fibaroScenes, i, j, len, len1, room, scene, sceneCmd, scenes;
      fibaroScenes = data;
      scenes = [];
      for (i = 0, len = fibaroScenes.length; i < len; i++) {
        fibaroScene = fibaroScenes[i];
        if (!"roomID" in fibaroScene) {
          continue;
        }
        for (j = 0, len1 = rooms.length; j < len1; j++) {
          room = rooms[j];
          if (!(("id" in room) && ("name" in room))) {
            continue;
          }
          if (room.id === fibaroScene.roomID) {
            sceneCmd = this.serverDef.url + "/api/sceneControl?id=" + fibaroScene.id + "&action=start";
            scene = {
              actionNum: fibaroScene.id,
              actionName: fibaroScene.name,
              groupName: room.name,
              actionUrl: sceneCmd
            };
            scenes.push(scene);
            break;
          }
        }
      }
      return scenes;
    }

  };

}).call(this);


//# sourceMappingURL=fibaro-server.js.map
//# sourceURL=coffeescript
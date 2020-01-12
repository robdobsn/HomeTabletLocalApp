(function() {
  App.VeraServer = class VeraServer {
    constructor(manager, serverDef, veraReadyCallback) {
      this.manager = manager;
      this.serverDef = serverDef;
      this.veraReadyCallback = veraReadyCallback;
      this.ACTIONS_URI = this.serverDef.url + "/data_request?id=user_data2&output_format=xml";
    }

    setReadyCallback(veraReadyCallback) {
      this.veraReadyCallback = veraReadyCallback;
    }

    reqActions() {
      return $.ajax(this.ACTIONS_URI, {
        type: "GET",
        dataType: "xml",
        crossDomain: true,
        success: (data, textStatus, jqXHR) => {
          this.rooms = this.getRooms(jqXHR.responseText);
          this.scenes = this.getScenes(jqXHR.responseText, this.rooms);
          this.scenes.sort(this.sortByRoomName);
          return this.veraReadyCallback(this.serverDef.name, this.scenes);
        }
      });
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

    getMatches(inText, re) {
      var grpInfo, matches, pos, text;
      matches = [];
      text = inText;
      while (true) {
        grpInfo = re.exec(text);
        if (grpInfo === null) {
          break;
        }
        pos = text.search(re);
        if (pos === -1) {
          break;
        }
        text = text.substring(pos + grpInfo[0].length);
        matches[matches.length] = grpInfo[1];
      }
      return matches;
    }

    getScenes(respText, rooms) {
      var i, len, matchScene, mtch, scenes, strMatches;
      scenes = [];
      matchScene = /<scene\b(.*?)>/;
      strMatches = this.getMatches(respText, matchScene);
      for (i = 0, len = strMatches.length; i < len; i++) {
        mtch = strMatches[i];
        this.addScene(scenes, mtch, rooms);
      }
      return scenes;
    }

    addScene(scenes, tagBody, rooms) {
      var grp1, grp2, grp3, re1, re2, re3, room, sceneCmd;
      re1 = /name="(.*?)"/;
      grp1 = re1.exec(tagBody);
      if (grp1 === null) {
        return;
      }
      re2 = /id="(.*?)"/;
      grp2 = re2.exec(tagBody);
      if (grp2 === null) {
        return;
      }
      re3 = /room="(.*?)"/;
      grp3 = re3.exec(tagBody);
      if (grp3 === null) {
        return;
      }
      room = "";
      if (grp3[1] in rooms) {
        room = rooms[grp3[1]];
      }
      sceneCmd = this.serverDef.url + "/data_request?id=lu_action&serviceId=urn:micasaverde-com:serviceId:HomeAutomationGateway1&action=RunScene&SceneNum=" + grp2[1];
      return scenes[scenes.length] = {
        actionNum: grp2[1],
        actionName: grp1[1],
        groupName: room,
        actionUrl: sceneCmd
      };
    }

    // console.log(grp2[1] + " " + grp1[1] + " " + room + " " + sceneCmd)
    getRooms(respText) {
      var i, len, matchRoom, mtch, rooms, strMatches;
      rooms = {};
      matchRoom = /<room\b(.*?)>/;
      strMatches = this.getMatches(respText, matchRoom);
      for (i = 0, len = strMatches.length; i < len; i++) {
        mtch = strMatches[i];
        this.addRoom(rooms, mtch);
      }
      return rooms;
    }

    addRoom(rooms, tagBody) {
      var grp1, grp2, re1, re2;
      re1 = /name="(.*?)"/;
      grp1 = re1.exec(tagBody);
      if (grp1 === null) {
        return;
      }
      re2 = /id="(.*?)"/;
      grp2 = re2.exec(tagBody);
      if (grp2 === null) {
        return;
      }
      return rooms[grp2[1]] = grp1[1];
    }

  };

}).call(this);


//# sourceMappingURL=vera-server.js.map
//# sourceURL=coffeescript
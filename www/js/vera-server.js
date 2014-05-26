// Generated by CoffeeScript 1.6.3
var VeraServer;

VeraServer = (function() {
  function VeraServer(serverURL) {
    this.serverURL = serverURL;
    this.ACTIONS_URI = this.serverURL + "/data_request?id=user_data2&output_format=xml";
  }

  VeraServer.prototype.setReadyCallback = function(veraReadyCallback) {
    this.veraReadyCallback = veraReadyCallback;
  };

  VeraServer.prototype.getActionGroups = function() {
    var _this = this;
    return $.ajax(this.ACTIONS_URI, {
      type: "GET",
      dataType: "xml",
      crossDomain: true,
      success: function(data, textStatus, jqXHR) {
        _this.rooms = _this.getRooms(jqXHR.responseText);
        _this.scenes = _this.getScenes(jqXHR.responseText, _this.rooms);
        _this.scenes.sort(_this.sortByRoomName);
        return _this.veraReadyCallback(_this.scenes);
      }
    });
  };

  VeraServer.prototype.sortByRoomName = function(a, b) {
    if (a.groupName < b.groupName) {
      return -1;
    }
    if (a.groupName > b.groupName) {
      return 1;
    }
    return 0;
  };

  VeraServer.prototype.getMatches = function(inText, re) {
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
  };

  VeraServer.prototype.getScenes = function(respText, rooms) {
    var matchScene, mtch, scenes, strMatches, _i, _len;
    scenes = [];
    matchScene = /<scene\b(.*?)>/;
    strMatches = this.getMatches(respText, matchScene);
    for (_i = 0, _len = strMatches.length; _i < _len; _i++) {
      mtch = strMatches[_i];
      this.addScene(scenes, mtch, rooms);
    }
    return scenes;
  };

  VeraServer.prototype.addScene = function(scenes, tagBody, rooms) {
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
    sceneCmd = this.serverURL + "/data_request?id=lu_action&serviceId=urn:micasaverde-com:serviceId:HomeAutomationGateway1&action=RunScene&SceneNum=" + grp2[1];
    return scenes[scenes.length] = {
      actionNum: grp2[1],
      actionName: grp1[1],
      groupName: room,
      actionUrl: sceneCmd
    };
  };

  VeraServer.prototype.getRooms = function(respText) {
    var matchRoom, mtch, rooms, strMatches, _i, _len;
    rooms = {};
    matchRoom = /<room\b(.*?)>/;
    strMatches = this.getMatches(respText, matchRoom);
    for (_i = 0, _len = strMatches.length; _i < _len; _i++) {
      mtch = strMatches[_i];
      this.addRoom(rooms, mtch);
    }
    return rooms;
  };

  VeraServer.prototype.addRoom = function(rooms, tagBody) {
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
  };

  return VeraServer;

})();

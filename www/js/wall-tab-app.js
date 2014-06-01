// Generated by CoffeeScript 1.6.3
var WallTabApp,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

WallTabApp = (function() {
  function WallTabApp() {
    this.actionOnUserIdle = __bind(this.actionOnUserIdle, this);
    this.automationServerReadyCb = __bind(this.automationServerReadyCb, this);
    this.configReadyCb = __bind(this.configReadyCb, this);
    this.rebuildUI = __bind(this.rebuildUI, this);
    this.tileColours = new TileColours;
    this.rdHomeServerUrl = "http://127.0.0.1:5000";
    this.calendarUrl = this.rdHomeServerUrl + "/calendars/api/v1.0/cal";
    this.automationActionsUrl = this.rdHomeServerUrl + "/automation/api/v1.0/actions";
    this.automationExecUrl = this.rdHomeServerUrl;
    this.sonosActionsUrl = this.rdHomeServerUrl + "/sonos/api/v1.0/actions";
    this.tabletConfigUrl = this.rdHomeServerUrl + "/tablet/api/v1.0/config";
    this.indigoServerUrl = "http://IndigoServer.local:8176";
    this.fibaroServerUrl = "http://192.168.0.69";
    this.veraServerUrl = "http://192.168.0.206:3480";
    this.frontDoorUrl = "http://192.168.0.221/";
    this.jsonConfig = {};
    window.soundClick = new Audio("audio/click.ogg");
    window.soundOk = new Audio("audio/blip.ogg");
    window.soundFail = new Audio("audio/fail.ogg");
  }

  WallTabApp.prototype.go = function() {
    var _this = this;
    $("body").append("<div id=\"sqWrapper\">\n</div>");
    this.userIdleCatcher = new UserIdleCatcher(30, this.actionOnUserIdle);
    this.setDefaultTabletConfig();
    this.automationActionGroups = [];
    this.automationServer = new AutomationServer(this.automationActionsUrl, this.automationExecUrl, this.veraServerUrl, this.indigoServerUrl, this.fibaroServerUrl, this.sonosActionsUrl);
    this.automationServer.setReadyCallback(this.automationServerReadyCb);
    this.tabletConfig = new TabletConfig(this.tabletConfigUrl);
    this.tabletConfig.setReadyCallback(this.configReadyCb);
    this.tileTiers = new TileTiers("#sqWrapper");
    $(window).on('orientationchange', function() {
      return _this.tileTiers.reDoLayout();
    });
    $(window).on('resize', function() {
      return _this.tileTiers.reDoLayout();
    });
    this.rebuildUI();
    this.requestActionAndConfigData();
    return setInterval(function() {
      return _this.requestActionAndConfigData();
    }, 600000);
  };

  WallTabApp.prototype.requestActionAndConfigData = function() {
    this.automationServer.getActionGroups();
    return this.tabletConfig.initTabletConfig();
  };

  WallTabApp.prototype.setDefaultTabletConfig = function() {
    var groupDefinitions, tileDefinitions;
    groupDefinitions = [
      {
        tierName: "mainTier",
        groupName: "Home"
      }, {
        tierName: "mainTier",
        groupName: "Calendar"
      }, {
        tierName: "actionsTier",
        groupName: "Lights"
      }, {
        tierName: "sonosTier",
        groupName: "Sonos"
      }, {
        tierName: "sonosTier",
        groupName: "Kids"
      }, {
        tierName: "doorBlindsTier",
        groupName: "Front Door"
      }, {
        tierName: "calendarTier",
        groupName: "Today"
      }
    ];
    this.jsonConfig["groupDefinitions"] = groupDefinitions;
    tileDefinitions = [
      {
        tierName: "mainTier",
        groupName: "Calendar",
        colSpan: 2,
        rowSpan: 2,
        uri: "",
        name: "calendar",
        visibility: "all",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 0
      }, {
        tierName: "calendarTier",
        groupName: "Today",
        colSpan: 2,
        rowSpan: 3,
        uri: "",
        name: "calendar",
        visibility: "all",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 0
      }, {
        tierName: "calendarTier",
        groupName: "Tomorrow",
        colSpan: 2,
        rowSpan: 3,
        uri: "",
        name: "calendar",
        visibility: "all",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 1
      }, {
        tierName: "calendarTier",
        groupName: "Today + 2",
        colSpan: 2,
        rowSpan: 3,
        uri: "",
        name: "calendar",
        visibility: "all",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 2
      }, {
        tierName: "calendarTier",
        groupName: "Today + 3",
        colSpan: 2,
        rowSpan: 3,
        uri: "",
        name: "calendar",
        visibility: "all",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 3
      }, {
        tierName: "calendarTier",
        groupName: "Today + 4",
        colSpan: 2,
        rowSpan: 3,
        uri: "",
        name: "calendar",
        visibility: "all",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 4
      }, {
        tierName: "mainTier",
        groupName: "Calendar",
        colSpan: 2,
        rowSpan: 1,
        uri: "",
        name: "clock",
        visibility: "all",
        tileType: "clock",
        iconName: "none"
      }
    ];
    return this.jsonConfig["tileDefinitions"] = tileDefinitions;
  };

  WallTabApp.prototype.makeTileFromTileDef = function(tileDef) {
    if (tileDef.tileType === "calendar") {
      return this.makeCalendarTile(tileDef);
    } else if (tileDef.tileType === "clock") {
      return this.makeClockTile(tileDef);
    } else {
      return this.makeSceneTile(tileDef);
    }
  };

  WallTabApp.prototype.tileBasicsFromDef = function(tileDef) {
    var tierIdx, tileBasics, tileColour;
    tileColour = this.tileColours.getNextColour();
    tierIdx = this.tileTiers.findTierIdx(tileDef.tierName);
    if (tierIdx < 0) {
      return null;
    }
    return tileBasics = new TileBasics(tileColour, tileDef.colSpan, tileDef.rowSpan, this.automationServer.executeCommand, tileDef.uri, tileDef.name, tileDef.visibility, this.tileTiers.getTileTierSelector(tileDef.tierName), tileDef.tileType, tileDef.iconName);
  };

  WallTabApp.prototype.makeCalendarTile = function(tileDef) {
    var tile, tileBasics;
    tileBasics = this.tileBasicsFromDef(tileDef);
    if (tileBasics === null) {
      return;
    }
    tile = new CalendarTile(tileBasics, this.calendarUrl, tileDef.calDayIndex);
    return this.addTileToTierGroup(tileDef.tierName, tileDef.groupName, tile);
  };

  WallTabApp.prototype.makeClockTile = function(tileDef) {
    var tile, tileBasics;
    tileBasics = this.tileBasicsFromDef(tileDef);
    if (tileBasics === null) {
      return;
    }
    tile = new Clock(tileBasics);
    return this.addTileToTierGroup(tileDef.tierName, tileDef.groupName, tile);
  };

  WallTabApp.prototype.makeSceneTile = function(tileDef) {
    var tile, tileBasics;
    tileBasics = this.tileBasicsFromDef(tileDef);
    if (tileBasics === null) {
      return;
    }
    tile = new SceneButton(tileBasics, tileDef.name);
    return this.addTileToTierGroup(tileDef.tierName, tileDef.groupName, tile);
  };

  WallTabApp.prototype.addTileToTierGroup = function(tierName, groupName, tile) {
    var groupIdx, tierIdx;
    tierIdx = this.tileTiers.findTierIdx(tierName);
    if (tierIdx < 0) {
      tierIdx = this.tileTiers.findTierIdx("actionsTier");
    }
    if (tierIdx < 0) {
      return;
    }
    if (groupName === "") {
      groupName = "Lights";
    }
    groupIdx = this.getUIGroupIdxAddGroupIfReqd(tierIdx, groupName);
    return this.tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile);
  };

  WallTabApp.prototype.rebuildUI = function() {
    var action, actionList, servType, tierName, tileDef, _i, _len, _ref;
    this.tileTiers.removeAll();
    this.applyTierAndGroupConfig(this.jsonConfig);
    _ref = this.automationActionGroups;
    for (servType in _ref) {
      actionList = _ref[servType];
      for (_i = 0, _len = actionList.length; _i < _len; _i++) {
        action = actionList[_i];
        tierName = "tierName" in action ? action.tierName : "actionsTier";
        tileDef = {
          tierName: tierName,
          groupName: action.groupName,
          colSpan: 1,
          rowSpan: 1,
          uri: action.actionUrl,
          name: action.actionName,
          visibility: "all",
          tileType: "action",
          iconName: "iconName" in action ? action.iconName : "bulb-on"
        };
        this.makeTileFromTileDef(tileDef);
      }
    }
    this.applyTileConfig(this.jsonConfig);
    return this.tileTiers.reDoLayout();
  };

  WallTabApp.prototype.getUIGroupIdxAddGroupIfReqd = function(tierIdx, groupName) {
    var groupIdx;
    if (groupName === "") {
      return -1;
    }
    groupIdx = this.tileTiers.findGroupIdx(tierIdx, groupName);
    if (groupIdx < 0) {
      groupIdx = this.tileTiers.addGroup(tierIdx, groupName);
    }
    return groupIdx;
  };

  WallTabApp.prototype.applyTierAndGroupConfig = function(jsonConfig) {
    var groupDef, groupIdx, newTier, tierIdx, _i, _len, _ref, _results;
    _ref = jsonConfig.groupDefinitions;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      groupDef = _ref[_i];
      tierIdx = this.tileTiers.findTierIdx(groupDef.tierName);
      if (tierIdx < 0) {
        newTier = new TileTier("#sqWrapper", groupDef.tierName);
        newTier.addToDom();
        tierIdx = this.tileTiers.addTier(newTier);
      }
      _results.push(groupIdx = this.getUIGroupIdxAddGroupIfReqd(tierIdx, groupDef.groupName));
    }
    return _results;
  };

  WallTabApp.prototype.applyTileConfig = function(jsonConfig) {
    var exTile, favouriteDefn, tb, tileDef, _i, _j, _len, _len1, _ref, _ref1;
    if ("tileDefinitions" in jsonConfig) {
      _ref = jsonConfig.tileDefinitions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tileDef = _ref[_i];
        this.makeTileFromTileDef(tileDef);
      }
    }
    if ("favourites" in jsonConfig) {
      _ref1 = jsonConfig.favourites;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        favouriteDefn = _ref1[_j];
        exTile = this.tileTiers.findExistingTile(favouriteDefn.tileName);
        if (exTile !== null) {
          tb = exTile.tileBasics;
          tileDef = {
            tierName: "mainTier",
            groupName: "Home",
            colSpan: tb.colSpan,
            rowSpan: tb.rowSpan,
            uri: tb.clickParam,
            name: tb.tileName,
            visibility: tb.visibility,
            tileType: tb.tileType,
            iconName: tb.iconName
          };
          this.makeTileFromTileDef(tileDef);
        }
      }
    }
  };

  WallTabApp.prototype.configReadyCb = function(inConfig) {
    var k, v;
    for (k in inConfig) {
      v = inConfig[k];
      this.jsonConfig[k] = v;
    }
    return this.rebuildUI();
  };

  WallTabApp.prototype.automationServerReadyCb = function(actions, serverType) {
    if (this.checkActionGroupsChanged(this.automationActionGroups, actions)) {
      this.automationActionGroups = actions;
      return this.rebuildUI();
    }
  };

  WallTabApp.prototype.checkActionGroupsChanged = function(oldActionMap, newActionMap) {
    var newActions, oldActions, servType;
    if (Object.keys(oldActionMap).length !== Object.keys(newActionMap).length) {
      return true;
    }
    for (servType in oldActionMap) {
      oldActions = oldActionMap[servType];
      if (!(servType in newActionMap)) {
        return true;
      }
      newActions = newActionMap[servType];
      if (this.checkActionsForServer(oldActions, newActions)) {
        return true;
      }
    }
    return false;
  };

  WallTabApp.prototype.checkActionsForServer = function(oldActions, newActions) {
    var j, k, newAction, oldAction, v, _i, _len;
    if (oldActions.length !== newActions.length) {
      return true;
    }
    for (j = _i = 0, _len = oldActions.length; _i < _len; j = ++_i) {
      oldAction = oldActions[j];
      newAction = newActions[j];
      if (Object.keys(oldAction).length !== Object.keys(newAction).length) {
        return true;
      }
      for (k in oldAction) {
        v = oldAction[k];
        if (!k in newAction) {
          return true;
        }
        if (v !== newAction[k]) {
          return true;
        }
      }
    }
    return false;
  };

  WallTabApp.prototype.actionOnUserIdle = function() {
    $("html, body").animate({
      scrollLeft: "0px"
    });
    return $("html, body").animate({
      scrollUp: "0px"
    });
  };

  return WallTabApp;

})();

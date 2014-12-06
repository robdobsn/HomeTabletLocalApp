// Generated by CoffeeScript 1.7.1
var WallTabApp,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

WallTabApp = (function() {
  function WallTabApp() {
    this.navigateTo = __bind(this.navigateTo, this);
    this.actionOnUserIdle = __bind(this.actionOnUserIdle, this);
    this.automationServerReadyCb = __bind(this.automationServerReadyCb, this);
    this.configReadyCb = __bind(this.configReadyCb, this);
    this.rebuildUI = __bind(this.rebuildUI, this);
    this.tileColours = new TileColours;
    this.rdHomeServerUrl = "http://macallan:5000";
    this.calendarUrl = "http://macallan:5077/calendar/min/4";
    this.automationActionsUrl = this.rdHomeServerUrl + "/automation/api/v1.0/actions";
    this.automationExecUrl = this.rdHomeServerUrl;
    this.sonosActionsUrl = "";
    this.tabletConfigUrl = "http://macallan:5076/tabletconfig";
    this.indigoServerUrl = "http://IndigoServer.local:8176";
    this.fibaroServerUrl = "http://192.168.0.69";
    this.veraServerUrl = "http://192.168.0.206:3480";
    this.jsonConfig = {};
    this.mediaPlayHelper = new MediaPlayHelper({
      click: "assets/click.mp3",
      ok: "assets/blip.mp3",
      fail: "assets/fail.mp3"
    });
    this.lastScrollEventTime = 0;
    this.minTimeBetweenScrolls = 1000;
    this.hoursBetweenActionUpdates = 12;
  }

  WallTabApp.prototype.go = function() {
    $("body").prepend("<div id=\"sqWrapper\">\n</div>");
    this.userIdleCatcher = new UserIdleCatcher(30, this.actionOnUserIdle);
    this.setDefaultTabletConfig();
    this.automationActionGroups = [];
    this.automationServer = new AutomationServer(this.automationActionsUrl, this.automationExecUrl, this.veraServerUrl, this.indigoServerUrl, this.fibaroServerUrl, this.sonosActionsUrl, this.mediaPlayHelper, this.navigateTo);
    this.automationServer.setReadyCallback(this.automationServerReadyCb);
    this.tabletConfig = new TabletConfig(this.tabletConfigUrl);
    this.tabletConfig.setReadyCallback(this.configReadyCb);
    this.tileTiers = new TileTiers("#sqWrapper");
    $(window).on('orientationchange', (function(_this) {
      return function() {
        return _this.tileTiers.reDoLayout();
      };
    })(this));
    $(window).on('resize', (function(_this) {
      return function() {
        return _this.tileTiers.reDoLayout();
      };
    })(this));
    this.rebuildUI();
    $(document).scrollsnap({
      snaps: '.snap',
      proximity: 250
    });
    this.requestActionAndConfigData();
    return setInterval((function(_this) {
      return function() {
        return _this.requestActionAndConfigData();
      };
    })(this), this.hoursBetweenActionUpdates * 60 * 60 * 1000);
  };

  WallTabApp.prototype.requestActionAndConfigData = function() {
    this.automationServer.getActionGroups();
    return this.tabletConfig.requestConfig();
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
        uri: "~~~calendarTier",
        name: "calendar",
        visibility: "landscape",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 0
      }, {
        tierName: "mainTier",
        groupName: "Home",
        colSpan: 3,
        rowSpan: 1,
        uri: "~~~calendarTier",
        name: "calendar",
        visibility: "portrait",
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
        visibility: "landscape",
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
        visibility: "landscape",
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
        visibility: "landscape",
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
        visibility: "landscape",
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
        visibility: "landscape",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 4
      }, {
        tierName: "calendarTier",
        groupName: "Today",
        colSpan: 3,
        rowSpan: 5,
        uri: "",
        name: "calendar",
        visibility: "portrait",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 0
      }, {
        tierName: "calendarTier",
        groupName: "Tomorrow",
        colSpan: 3,
        rowSpan: 5,
        uri: "",
        name: "calendar",
        visibility: "portrait",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 1
      }, {
        tierName: "calendarTier",
        groupName: "Today + 2",
        colSpan: 3,
        rowSpan: 5,
        uri: "",
        name: "calendar",
        visibility: "portrait",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 2
      }, {
        tierName: "calendarTier",
        groupName: "Today + 3",
        colSpan: 3,
        rowSpan: 5,
        uri: "",
        name: "calendar",
        visibility: "portrait",
        tileType: "calendar",
        iconName: "none",
        calDayIndex: 3
      }, {
        tierName: "calendarTier",
        groupName: "Today + 4",
        colSpan: 3,
        rowSpan: 5,
        uri: "",
        name: "calendar",
        visibility: "portrait",
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
        visibility: "landscape",
        tileType: "clock",
        iconName: "none"
      }, {
        tierName: "mainTier",
        groupName: "Home",
        colSpan: 3,
        rowSpan: 1,
        uri: "",
        name: "clock",
        visibility: "portrait",
        tileType: "clock",
        iconName: "none"
      }, {
        tierName: "mainTier",
        groupName: "Config",
        colSpan: 1,
        rowSpan: 1,
        uri: "",
        name: "TabName",
        visibility: "landscape",
        tileType: "config",
        iconName: "config",
        configType: "tabname",
        clickFn: this.configTabNameClick,
        groupPriority: 0
      }
    ];
    return this.jsonConfig["tileDefs_static"] = tileDefinitions;
  };

  WallTabApp.prototype.makeTileFromTileDef = function(tileDef) {
    if (tileDef.tileType === "calendar") {
      return this.makeCalendarTile(tileDef);
    } else if (tileDef.tileType === "clock") {
      return this.makeClockTile(tileDef);
    } else if (tileDef.tileType === "config") {
      return this.makeConfigTile(tileDef);
    } else {
      return this.makeSceneTile(tileDef);
    }
  };

  WallTabApp.prototype.tileBasicsFromDef = function(tileDef) {
    var clickFn, isFavourite, tierIdx, tileBasics, tileColour;
    tileColour = this.tileColours.getNextColour();
    tierIdx = this.tileTiers.findTierIdx(tileDef.tierName);
    if (tierIdx < 0) {
      return null;
    }
    if ((tileDef.isFavourite != null) && tileDef.isFavourite) {
      isFavourite = true;
    }
    clickFn = this.automationServer.executeCommand;
    if ("clickFn" in tileDef) {
      clickFn = tileDef.clickFn;
    }
    return tileBasics = new TileBasics(tileColour, tileDef.colSpan, tileDef.rowSpan, clickFn, tileDef.uri, tileDef.name, tileDef.visibility, this.tileTiers.getTileTierSelector(tileDef.tierName), tileDef.tileType, tileDef.iconName, isFavourite, this.mediaPlayHelper);
  };

  WallTabApp.prototype.makeCalendarTile = function(tileDef) {
    var tile, tileBasics;
    tileBasics = this.tileBasicsFromDef(tileDef);
    if (tileBasics === null) {
      return;
    }
    tile = new CalendarTile(tileBasics, this.calendarUrl, tileDef.calDayIndex);
    return this.addTileToTierGroup(tileDef, tile);
  };

  WallTabApp.prototype.makeClockTile = function(tileDef) {
    var tile, tileBasics;
    tileBasics = this.tileBasicsFromDef(tileDef);
    if (tileBasics === null) {
      return;
    }
    tile = new Clock(tileBasics);
    return this.addTileToTierGroup(tileDef, tile);
  };

  WallTabApp.prototype.makeConfigTile = function(tileDef) {
    var tile, tileBasics;
    tileBasics = this.tileBasicsFromDef(tileDef);
    if (tileBasics === null) {
      return;
    }
    tile = new ConfigTile(tileBasics, tileDef.configType);
    return this.addTileToTierGroup(tileDef, tile);
  };

  WallTabApp.prototype.makeSceneTile = function(tileDef) {
    var tile, tileBasics;
    tileBasics = this.tileBasicsFromDef(tileDef);
    if (tileBasics === null) {
      return;
    }
    tile = new SceneButton(tileBasics, tileDef.name);
    return this.addTileToTierGroup(tileDef, tile);
  };

  WallTabApp.prototype.addTileToTierGroup = function(tileDef, tile) {
    var groupIdx, groupName, groupPriority, tierIdx, tierName;
    tierName = tileDef.tierName;
    groupName = tileDef.groupName;
    groupPriority = "groupPriority" in tileDef ? tileDef.groupPriority : 5;
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
    groupIdx = this.getUIGroupIdxAddGroupIfReqd(tierIdx, groupName, groupPriority);
    return this.tileTiers.addTileToTierGroup(tierIdx, groupIdx, tile);
  };

  WallTabApp.prototype.rebuildUI = function() {
    var action, actionList, iconName, servType, tierName, tileDef, _i, _len, _ref;
    this.tileTiers.removeAll();
    this.applyTierAndGroupConfig(this.jsonConfig);
    _ref = this.automationActionGroups;
    for (servType in _ref) {
      actionList = _ref[servType];
      for (_i = 0, _len = actionList.length; _i < _len; _i++) {
        action = actionList[_i];
        tierName = "tierName" in action ? action.tierName : "actionsTier";
        iconName = "iconName" in action ? action.iconName : "";
        tileDef = {
          tierName: tierName,
          groupName: action.groupName,
          colSpan: 1,
          rowSpan: 1,
          uri: action.actionUrl,
          name: action.actionName,
          visibility: "all",
          tileType: "action",
          iconName: iconName
        };
        this.makeTileFromTileDef(tileDef);
      }
    }
    this.applyTileConfig(this.jsonConfig);
    return this.tileTiers.reDoLayout();
  };

  WallTabApp.prototype.getUIGroupIdxAddGroupIfReqd = function(tierIdx, groupName, groupPriority) {
    var groupIdx;
    if (groupName === "") {
      return -1;
    }
    groupIdx = this.tileTiers.findGroupIdx(tierIdx, groupName);
    if (groupIdx < 0) {
      groupIdx = this.tileTiers.addGroup(tierIdx, groupName, groupPriority);
    }
    return groupIdx;
  };

  WallTabApp.prototype.applyTierAndGroupConfig = function(jsonConfig) {
    var groupDef, groupIdx, groupPriority, newTier, tierIdx, _i, _len, _ref, _results;
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
      groupPriority = "groupPriority" in groupDef ? groupDef.groupPriority : 5;
      _results.push(groupIdx = this.getUIGroupIdxAddGroupIfReqd(tierIdx, groupDef.groupName, groupPriority));
    }
    return _results;
  };

  WallTabApp.prototype.applyTileConfig = function(jsonConfig) {
    var destGroupName, exTile, favouriteDefn, favourites, key, tb, tileDef, val, _i, _j, _len, _len1;
    favourites = {};
    for (key in jsonConfig) {
      val = jsonConfig[key];
      if (key === "favourites") {
        favourites = val;
      } else if (key.search(/tileDefs_/) === 0) {
        for (_i = 0, _len = val.length; _i < _len; _i++) {
          tileDef = val[_i];
          this.makeTileFromTileDef(tileDef);
        }
      }
    }
    for (_j = 0, _len1 = favourites.length; _j < _len1; _j++) {
      favouriteDefn = favourites[_j];
      exTile = this.tileTiers.findExistingTile(favouriteDefn.tileName, favouriteDefn.groupName);
      if (exTile !== null) {
        tb = exTile.tileBasics;
        destGroupName = "destGroup" in favouriteDefn ? favouriteDefn["destGroup"] : "Home";
        tileDef = {
          tierName: "mainTier",
          groupName: destGroupName,
          colSpan: tb.colSpan,
          rowSpan: tb.rowSpan,
          uri: tb.clickParam,
          name: tb.tileName,
          visibility: tb.visibility,
          tileType: tb.tileType,
          iconName: tb.iconName,
          isFavourite: true
        };
        this.makeTileFromTileDef(tileDef);
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
    if ($(window).scrollLeft() === 0 && $(window).scrollTop() < 20) {
      return;
    }
    console.log("ScrollTop = " + $(window).scrollTop());
    return $("html, body").animate({
      scrollTop: "0px"
    }, 200).animate({
      scrollLeft: "0px"
    }, 200);
  };

  WallTabApp.prototype.navigateTo = function(tierName) {
    var tierTop;
    tierTop = this.tileTiers.getTierTop(tierName);
    if (tierTop >= 0) {
      return $("html, body").stop().animate({
        scrollTop: tierTop
      }, 200);
    }
  };

  WallTabApp.prototype.configTabNameClick = function() {
    var tabName;
    tabName = LocalStorage.get("DeviceConfigName");
    if (tabName == null) {
      tabName = "";
    }
    $("#tabnamefield").val(tabName);
    $("#tabnameok").unbind("click");
    $("#tabnameok").click(function() {
      LocalStorage.set("DeviceConfigName", $("#tabnamefield").val());
      return $("#tabnameform").hide();
    });
    return $("#tabnameform").show();
  };

  return WallTabApp;

})();

// Generated by CoffeeScript 1.10.0
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  App.WallTabApp = (function() {
    function WallTabApp() {
      this.actionOnUserIdle = bind(this.actionOnUserIdle, this);
      this.automationManagerReadyCb = bind(this.automationManagerReadyCb, this);
      this.tabletConfigReadyCb = bind(this.tabletConfigReadyCb, this);
      this.defaultTabletName = "tabdefault";
      this.hoursBetweenActionUpdates = 12;
      this.minsBetweenEventLogChecks = 1;
      this.maxEventsPerLogSend = 50;
      this.mediaPlayHelper = new App.MediaPlayHelper({
        "click": "assets/click.mp3",
        "ok": "assets/blip.mp3",
        "fail": "assets/fail-doh.mp3"
      });
      this.tileColours = new App.TileColours;
      return;
    }

    WallTabApp.prototype.getLogServerUrl = function() {
      return App.LocalStorage.get("ConfigServerUrl") + "/log";
    };

    WallTabApp.prototype.go = function() {
      this.userIdleCatcher = new App.UserIdleCatcher(90, this.actionOnUserIdle);
      this.tabletConfigManager = new App.TabletConfigManager(this.defaultTabletName);
      this.tabletConfigManager.setReadyCallback(this.tabletConfigReadyCb);
      this.automationManager = new App.AutomationManager(this, this.automationManagerReadyCb);
      this.calendarManager = new App.CalendarManager(this);
      this.appPages = new App.AppPages(this, "#sqWrapper", this.automationManager);
      $(window).on('orientationchange', (function(_this) {
        return function() {
          return _this.buildAndDisplayUI();
        };
      })(this));
      $(window).on('resize', (function(_this) {
        return function() {
          return _this.buildAndDisplayUI();
        };
      })(this));
      this.checkEventLogs();
      setInterval((function(_this) {
        return function() {
          return _this.checkEventLogs();
        };
      })(this), this.minsBetweenEventLogChecks * 60 * 1000);
      this.requestConfigData();
      setInterval((function(_this) {
        return function() {
          return _this.requestConfigData();
        };
      })(this), this.hoursBetweenActionUpdates * 60 * 60 * 1000);
    };

    WallTabApp.prototype.requestConfigData = function() {
      return this.tabletConfigManager.requestConfig();
    };

    WallTabApp.prototype.tabletConfigReadyCb = function() {
      var configData;
      configData = this.tabletConfigManager.getConfigData();
      if ((configData.common != null) && (configData.common.calendar != null)) {
        this.calendarManager.setConfig(configData.common.calendar);
      }
      return this.automationManager.requestUpdate(configData);
    };

    WallTabApp.prototype.automationManagerReadyCb = function(hasChanged) {
      if (hasChanged) {
        return this.buildAndDisplayUI();
      }
    };

    WallTabApp.prototype.buildAndDisplayUI = function() {
      this.appPages.build(this.automationManager.getActionGroups());
      return this.appPages.display();
    };

    WallTabApp.prototype.actionOnUserIdle = function() {
      this.appPages.userIsIdle();
    };

    WallTabApp.prototype.checkEventLogs = function() {
      var ev, evList, evListJson, i, j, k, len, logCat, logCats, ref;
      evList = [];
      logCats = ["CalLog", "IndLog", "CnfLog"];
      for (j = 0, len = logCats.length; j < len; j++) {
        logCat = logCats[j];
        for (i = k = 0, ref = this.maxEventsPerLogSend; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
          ev = App.LocalStorage.getEvent(logCat);
          if (ev != null) {
            console.log("Logging event from " + logCat + " = " + JSON.stringify(ev));
            evList.push({
              logCat: logCat,
              timestamp: ev.timestamp,
              eventText: ev.eventText
            });
          } else {
            break;
          }
        }
      }
      if (evList.length > 0) {
        evListJson = JSON.stringify(evList);
        console.log("Sending " + evList.length + " log event(s) to log server");
        $.ajax({
          url: this.getLogServerUrl(),
          type: 'POST',
          data: evListJson,
          contentType: "application/json",
          success: (function(_this) {
            return function(data, status, response) {
              console.log("logged events success");
            };
          })(this),
          error: (function(_this) {
            return function(jqXHR, textStatus, errorThrown) {
              var l, len1;
              console.log("Error log failed: " + textStatus + " " + errorThrown);
              for (l = 0, len1 = evList.length; l < len1; l++) {
                ev = evList[l];
                App.LocalStorage.logEvent(ev.logCat, ev.eventText, ev.timestamp);
              }
            };
          })(this)
        });
      }
    };

    return WallTabApp;

  })();

}).call(this);

//# sourceMappingURL=wall-tab-app.js.map

(function() {
  App.WallTabApp = class WallTabApp {
    constructor() {
      this.tabletConfigReadyCb = this.tabletConfigReadyCb.bind(this);
      this.automationManagerReadyCb = this.automationManagerReadyCb.bind(this);
      this.actionOnUserIdle = this.actionOnUserIdle.bind(this);
      console.log("WallTabletDebug APPLICATION STARTING UP");
      // Default the tablet name and get the configuration server
      this.defaultTabletName = "tabdefault";
      // Basic settings
      this.hoursBetweenActionUpdates = 12;
      this.minsBetweenEventLogChecks = 1;
      this.maxEventsPerLogSend = 50;
      // Helper for playing media files
      this.mediaPlayHelper = new App.MediaPlayHelper({
        "click": "assets/click.mp3",
        "ok": "assets/ok.mp3",
        "fail": "assets/fail-wah.mp3"
      });
      this.tileColours = new App.TileColours;
      return;
    }

    getLogServerUrl() {
      return App.LocalStorage.get("ConfigServerUrl") + "/log";
    }

    go() {
      // Goes back to home display after user idle timeout
      this.userIdleCatcher = new App.UserIdleCatcher(90, this.actionOnUserIdle);
      // Tablet config is based on the name or IP address of the tablet
      this.tabletConfigManager = new App.TabletConfigManager(this.defaultTabletName);
      this.tabletConfigManager.setReadyCallback(this.tabletConfigReadyCb);
      // Automation manager handles communicaton with automaion devices like
      // Indigo/vera/fibaro
      this.automationManager = new App.AutomationManager(this, this.automationManagerReadyCb);
      // Calendar server communications
      this.calendarManager = new App.CalendarManager(this);
      // App Pages
      this.appPages = new App.AppPages(this, "#sqWrapper", this.automationManager);
      // Handler for orientation change
      $(window).on('orientationchange', () => {
        return this.buildAndDisplayUI();
      });
      // And resize event
      $(window).on('resize', () => {
        return this.buildAndDisplayUI();
      });
      // Check event logs frequently
      this.checkEventLogs();
      setInterval(() => {
        return this.checkEventLogs();
      }, this.minsBetweenEventLogChecks * 60 * 1000);
      // Make initial requests for action (scene) data and config data and repeat requests at intervals
      this.requestConfigData();
      setInterval(() => {
        return this.requestConfigData();
      }, this.hoursBetweenActionUpdates * 60 * 60 * 1000);
    }

    requestConfigData() {
      // Request tablet configuration from config server
      return this.tabletConfigManager.requestConfig();
    }

    tabletConfigReadyCb() {
      var configData;
      // Configuration data is available
      configData = this.tabletConfigManager.getConfigData();
      if ((configData.common != null) && (configData.common.calendar != null)) {
        this.calendarManager.setConfig(configData.common.calendar);
      }
      return this.automationManager.requestUpdate(configData);
    }

    automationManagerReadyCb(hasChanged) {
      // Automation server data is available
      if (hasChanged) {
        return this.buildAndDisplayUI();
      }
    }

    buildAndDisplayUI() {
      this.appPages.build(this.automationManager.getActionGroups());
      return this.appPages.display();
    }

    actionOnUserIdle() {
      this.appPages.userIsIdle();
    }

    checkEventLogs() {
      var ev, evList, evListJson, i, j, k, len, logCat, logCats, ref;
      evList = [];
      logCats = ["CalLog", "IndLog", "CnfLog"];
      for (j = 0, len = logCats.length; j < len; j++) {
        logCat = logCats[j];
        for (i = k = 0, ref = this.maxEventsPerLogSend; (0 <= ref ? k < ref : k > ref); i = 0 <= ref ? ++k : --k) {
          ev = App.LocalStorage.getEvent(logCat);
          if (ev != null) {
            console.log("WallTabletDebug Logging event from " + logCat + " = " + JSON.stringify(ev));
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
        console.log("WallTabletDebug Sending " + evList.length + " log event(s) to log server");
        $.ajax({
          url: this.getLogServerUrl(),
          type: 'POST',
          data: evListJson,
          contentType: "application/json",
          success: (data, status, response) => {
            console.log("WallTabletDebug logged events success");
          },
          error: (jqXHR, textStatus, errorThrown) => {
            var l, len1;
            console.log("WallTabletDebug Error log failed: " + textStatus + " " + errorThrown);
// If logging failed then re-log the events
            for (l = 0, len1 = evList.length; l < len1; l++) {
              ev = evList[l];
              App.LocalStorage.logEvent(ev.logCat, ev.eventText, ev.timestamp);
            }
          }
        });
      }
    }

  };

}).call(this);


//# sourceMappingURL=wall-tab-app.js.map
//# sourceURL=coffeescript
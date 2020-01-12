(function() {
  App.TabletConfigManager = class TabletConfigManager {
    constructor(defaultTabletName) {
      this.defaultTabletName = defaultTabletName;
      this.configData = {};
      this.defaultTabletConfig = new App.DefaultTabletConfig();
      this.defaultConfigSettings = {
        showCalServerSetting: true,
        showAutomationServerSettings: ["Indigo", "Vera", "Fibaro"],
        showEnergyServerSetting: true
      };
      return;
    }

    getTabName() {
      var tabName;
      // See if the tablet's name is in the local storage
      tabName = App.LocalStorage.get("DeviceConfigName");
      if ((tabName == null) || tabName === "") {
        tabName = this.defaultTabletName;
      }
      return tabName;
    }

    getReqUrl() {
      var reqURL, tabName;
      reqURL = App.LocalStorage.get("ConfigServerUrl");
      if ((reqURL == null) || reqURL === "") {
        return "";
      }
      tabName = this.getTabName();
      reqURL = reqURL.trim();
      reqURL = reqURL + (reqURL.slice(-1) === "/" ? "" : "/") + "tabletconfig/" + tabName;
      return reqURL;
    }

    setReadyCallback(readyCallback) {
      this.readyCallback = readyCallback;
    }

    getConfigData() {
      return this.configData;
    }

    addFavouriteButton(buttonInfo) {
      console.log("Add " + buttonInfo.tileName);
      if (!("favourites" in this.configData)) {
        this.configData.favourites = [];
      }
      this.configData.favourites.push({
        tileName: buttonInfo.tileName,
        groupName: buttonInfo.groupName
      });
      return this.saveDeviceConfig();
    }

    deleteFavouriteButton(buttonInfo) {
      var fav, favIdx, i, idx, len, ref;
      console.log("Delete " + buttonInfo.tileName);
      if (!("favourites" in this.configData)) {
        return;
      }
      favIdx = -1;
      ref = this.configData.favourites;
      for (idx = i = 0, len = ref.length; i < len; idx = ++i) {
        fav = ref[idx];
        if (fav.tileName === buttonInfo.tileName && fav.groupName === buttonInfo.groupName) {
          favIdx = idx;
          break;
        }
      }
      if (favIdx >= 0) {
        this.configData.favourites.splice(favIdx, 1);
        return this.saveDeviceConfig();
      }
    }

    saveDeviceConfig() {
      var reqURL, tabName;
      reqURL = this.getReqUrl();
      App.LocalStorage.set(reqURL, this.configData);
      tabName = this.getTabName();
      if ((tabName == null) || tabName === "") {
        console.log("WallTabletDebug Unable to save device config as tablet name unknown");
      } else {
        console.log("WallTabletDebug Saving device config for " + tabName);
      }
      // Store back to the server 
      return $.ajax({
        url: reqURL,
        type: 'POST',
        data: JSON.stringify({
          "favourites": this.configData.favourites
        }),
        contentType: "application/json",
        success: (data, status, response) => {
          return console.log("WallTabletDebug Sent new config data ok");
        },
        error: (jqXHR, textStatus, errorThrown) => {
          return console.error("WallTabletDebug Failed to send new config data: " + textStatus + " " + errorThrown);
        }
      });
    }

    requestConfig() {
      var reqURL, tabName;
      reqURL = this.getReqUrl();
      // Handle no config server situation
      if (reqURL === "") {
        this.configData = this.defaultTabletConfig.get(this.defaultConfigSettings);
        this.readyCallback();
        return;
      }
      // Get the configuration from the server
      tabName = this.getTabName();
      console.log("WallTabletDebug Requesting tablet config from tabname " + this.getTabName() + " using URL " + reqURL);
      // get the tablet config from a server
      this.catchAjaxFail = setTimeout(() => {
        return this.ajaxFailTimeout();
      }, 2000);
      $.ajax(reqURL, {
        type: "GET",
        dataType: "text",
        crossDomain: true,
        timeout: 1500,
        success: (data, textStatus, jqXHR) => {
          var curTabName, jsonData, jsonText;
          clearTimeout(this.catchAjaxFail);
          jsonText = jqXHR.responseText;
          jsonData = $.parseJSON(jsonText);
          if (jsonText === "{}") {
            console.log("WallTabletDebug Got tablet config but it's empty");
            this.configData = this.defaultTabletConfig.get(this.defaultConfigSettings);
          } else {
            console.log("WallTabletDebug Got tablet config data");
            tabName = jsonData["deviceName"];
            curTabName = App.LocalStorage.get("DeviceConfigName");
            if ((tabName != null) && tabName !== curTabName) {
              App.LocalStorage.set("DeviceConfigName", tabName);
              console.log("WallTabletDebug DeviceConfigName was " + curTabName + " now set to " + tabName);
              console.log("WallTabletDebug " + " TABLETCONFIG DeviceConfigName was " + curTabName + " now set to " + tabName);
              App.LocalStorage.logEvent("CnfLog", "DeviceConfigName was " + curTabName + " now set to " + tabName);
            }
            this.configData = jsonData;
            App.LocalStorage.set(reqURL, this.configData);
          }
          this.readyCallback();
          console.log("WallTabletDebug Storing data for " + reqURL + " = " + JSON.stringify(jsonData));
        },
        error: (jqXHR, textStatus, errorThrown) => {
          var storedData;
          console.log("WallTabletDebug Get tablet config data failed with an error " + textStatus);
          // Use stored data if available
          clearTimeout(this.catchAjaxFail);
          storedData = App.LocalStorage.get(reqURL);
          console.log("WallTabletDebug Config Getting data stored for " + reqURL + " result = " + storedData);
          if (storedData != null) {
            // console.log "Using stored data" + JSON.stringify(storedData)
            console.log("WallTabletDebug Using stored data for " + reqURL);
            this.configData = storedData;
          } else {
            this.configData = this.defaultTabletConfig.get(this.defaultConfigSettings);
          }
          this.readyCallback();
        }
      });
    }

    ajaxFailTimeout() {
      console.log("WallTabletDebug Get tablet config timed out via setTimeout");
      this.configData = this.defaultTabletConfig.get(this.defaultConfigSettings);
      this.readyCallback();
    }

  };

}).call(this);


//# sourceMappingURL=tablet-config.js.map
//# sourceURL=coffeescript
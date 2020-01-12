(function() {
  App.LocalStorage = class LocalStorage {
    static get(key) {
      var item, rslt;
      rslt = null;
      if (window.Storage && window.JSON) {
        item = localStorage.getItem(key);
        if (item) {
          rslt = JSON.parse(item);
        }
      }
      return rslt;
    }

    static set(key, value) {
      if (window.Storage && window.JSON) {
        localStorage.setItem(key, JSON.stringify(value));
        return true;
      }
      return false;
    }

    static logEvent(logKey, eventText, timestamp) {
      var logData, now;
      now = new Date();
      timestamp = timestamp != null ? timestamp : now;
      console.log("WallTabletDebug LogEvent: " + logKey + " text " + eventText + " time " + timestamp);
      logData = this.get(logKey);
      if (logData != null) {
        while (logData.length > 100) {
          logData.shift();
        }
      } else {
        logData = [];
      }
      logData.push({
        timestamp: timestamp,
        eventText: eventText
      });
      this.set(logKey, logData);
    }

    static formatDate(d) {
      return d.getFullYear() + "/" + this.padZero(d.getMonth() + 1, 2) + "/" + this.padZero(d.getDate(), 2) + " " + this.padZero(d.getHours(), 2) + ":" + this.padZero(d.getMinutes(), 2) + ":" + this.padZero(d.getSeconds(), 2);
    }

    static padZero(val, zeroes) {
      return ("00000000" + val).slice(-zeroes);
    }

    static getEventsText(logKey) {
      var ev, i, len, logData, outStr;
      logData = this.get(logKey);
      if (logData == null) {
        return "";
      }
      outStr = "";
      for (i = 0, len = logData.length; i < len; i++) {
        ev = logData[i];
        outStr += ev.timestamp + " " + ev.eventText + "\n";
      }
      return outStr;
    }

    static getEvent(logKey) {
      var logData, retEv;
      logData = this.get(logKey);
      if (logData == null) {
        return null;
      }
      if (logData.length <= 0) {
        return null;
      }
      retEv = logData.shift();
      this.set(logKey, logData);
      return retEv;
    }

  };

}).call(this);


//# sourceMappingURL=local-storage.js.map
//# sourceURL=coffeescript
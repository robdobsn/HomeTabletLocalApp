// Generated by CoffeeScript 1.10.0
(function() {
  App.CalendarManager = (function() {
    function CalendarManager(app) {
      this.app = app;
      this.calendarData = [];
      this.secsBetweenCalendarRefreshes = 60;
      this.firstRefreshAfterFailSecs = 10;
      this.nextRefreshesAfterFailSecs = 60;
      this.numRefreshFailuresSinceSuccess = 0;
      this.calendarUrl = "";
      this.calendarNumDays = 31;
      return;
    }

    CalendarManager.prototype.setConfig = function(config) {
      if (config.url != null) {
        this.calendarUrl = config.url;
      }
      if (config.numDays != null) {
        this.calendarNumDays = config.numDays;
      }
      this.requestCalUpdate();
    };

    CalendarManager.prototype.requestCalUpdate = function() {
      var dateTimeNow;
      if (this.calendarUrl === "") {
        return;
      }
      dateTimeNow = new Date();
      console.log("ReqCalUpdate at " + dateTimeNow.toTimeString() + " from " + this.calendarUrl);
      $.ajax(this.calendarUrl, {
        type: "GET",
        dataType: "text",
        crossDomain: true,
        success: (function(_this) {
          return function(data, textStatus, jqXHR) {
            var jsonData, jsonText;
            jsonText = jqXHR.responseText;
            jsonData = $.parseJSON(jsonText);
            _this.calendarData = jsonData;
            _this.numRefreshFailuresSinceSuccess = 0;
            console.log("Got calendar data");
          };
        })(this),
        error: (function(_this) {
          return function(jqXHR, textStatus, errorThrown) {
            App.LocalStorage.logEvent("CalLog", "AjaxFail Status = " + textStatus + " URL=" + _this.calendarUrl + " Error= " + errorThrown);
            console.log("GetCalError " + "ReqCalAjaxFailed TextStatus = " + textStatus + " ErrorThrown = " + errorThrown);
            _this.numRefreshFailuresSinceSuccess++;
            setTimeout(function() {
              return _this.requestCalUpdate;
            }, (_this.numRefreshFailuresSinceSuccess === 1 ? _this.firstRefreshAfterFailSecs * 1000 : _this.nextRefreshesAfterFailSecs * 1000));
          };
        })(this)
      });
    };

    CalendarManager.prototype.getCalData = function() {
      return this.calendarData;
    };

    CalendarManager.prototype.getCalNumDays = function() {
      return this.calendarNumDays;
    };

    return CalendarManager;

  })();

}).call(this);

//# sourceMappingURL=calendar-server.js.map

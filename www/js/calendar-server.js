(function() {
  App.CalendarManager = class CalendarManager {
    constructor(app) {
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

    setConfig(config) {
      if (config.url != null) {
        this.calendarUrl = config.url;
      }
      if (config.numDays != null) {
        this.calendarNumDays = config.numDays;
      }
      this.requestCalUpdate();
    }

    requestCalUpdate() {
      var dateTimeNow;
      if (this.calendarUrl === "") {
        return;
      }
      dateTimeNow = new Date();
      console.log("WallTabletDebug ReqCalUpdate at " + dateTimeNow.toTimeString() + " from " + this.calendarUrl);
      $.ajax(this.calendarUrl, {
        type: "GET",
        dataType: "text",
        crossDomain: true,
        success: (data, textStatus, jqXHR) => {
          var jsonData, jsonText;
          jsonText = jqXHR.responseText;
          jsonData = $.parseJSON(jsonText);
          this.calendarData = jsonData;
          this.numRefreshFailuresSinceSuccess = 0;
          console.log("WallTabletDebug Got calendar data");
        },
        error: (jqXHR, textStatus, errorThrown) => {
          console.log("WallTabletDebug " + " CALENDAR AjaxFail Status = " + textStatus + " URL=" + this.calendarUrl + " Error= " + errorThrown);
          App.LocalStorage.logEvent("CalLog", "AjaxFail Status = " + textStatus + " URL=" + this.calendarUrl + " Error= " + errorThrown);
          console.log("WallTabletDebug GetCalError " + "ReqCalAjaxFailed TextStatus = " + textStatus + " ErrorThrown = " + errorThrown);
          this.numRefreshFailuresSinceSuccess++;
          setTimeout(() => {
            return this.requestCalUpdate;
          }, (this.numRefreshFailuresSinceSuccess === 1 ? this.firstRefreshAfterFailSecs * 1000 : this.nextRefreshesAfterFailSecs * 1000));
        }
      });
    }

    getCalData() {
      return this.calendarData;
    }

    getCalNumDays() {
      return this.calendarNumDays;
    }

  };

}).call(this);


//# sourceMappingURL=calendar-server.js.map
//# sourceURL=coffeescript
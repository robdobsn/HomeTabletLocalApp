// Generated by CoffeeScript 1.8.0
var CalendarServer;

CalendarServer = (function() {
  function CalendarServer(app, calendarNumDays) {
    this.app = app;
    this.calendarNumDays = calendarNumDays;
    this.calendarData = [];
    this.secsBetweenCalendarRefreshes = 60;
    this.firstRefreshAfterFailSecs = 10;
    this.nextRefreshesAfterFailSecs = 60;
    this.numRefreshFailuresSinceSuccess = 0;
    this.requestCalUpdate();
    return;
  }

  CalendarServer.prototype.requestCalUpdate = function() {
    var dateTimeNow;
    dateTimeNow = new Date();
    console.log("ReqCalUpdate at " + dateTimeNow.toTimeString() + " from " + this.app.calendarUrl);
    $.ajax(this.app.calendarUrl, {
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
          LocalStorage.logEvent("CalLog", "AjaxFail Status = " + textStatus + " URL=" + _this.calendarUrl + " Error= " + errorThrown);
          console.log("GetCalError " + "ReqCalAjaxFailed TextStatus = " + textStatus + " ErrorThrown = " + errorThrown);
          _this.numRefreshFailuresSinceSuccess++;
          setTimeout(function() {
            return _this.requestCalUpdate;
          }, (_this.numRefreshFailuresSinceSuccess === 1 ? _this.firstRefreshAfterFailSecs * 1000 : _this.nextRefreshesAfterFailSecs * 1000));
        };
      })(this)
    });
  };

  CalendarServer.prototype.getCalData = function() {
    return this.calendarData;
  };

  CalendarServer.prototype.getCalNumDays = function() {
    return this.calendarNumDays;
  };

  return CalendarServer;

})();
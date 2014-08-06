// Generated by CoffeeScript 1.7.1
var CalendarTile,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

CalendarTile = (function(_super) {
  __extends(CalendarTile, _super);

  function CalendarTile(tileBasics, calendarURL, calDayIndex) {
    this.calendarURL = calendarURL;
    this.calDayIndex = calDayIndex;
    CalendarTile.__super__.constructor.call(this, tileBasics);
    this.shortDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    this.calLineCount = 0;
    this.calCharCount = 0;
    this.calMaxLineLen = 0;
    this.minutesBetweenCalendarRefreshes = 15;
  }

  CalendarTile.prototype.addToDoc = function() {
    CalendarTile.__super__.addToDoc.call(this);
    return this.setRefreshInterval(this.minutesBetweenCalendarRefreshes * 60, this.requestCalUpdate, true);
  };

  CalendarTile.prototype.requestCalUpdate = function() {
    var dateTimeNow;
    dateTimeNow = new Date();
    console.log("ReqCalUpdate at " + dateTimeNow.toTimeString() + " from " + this.calendarURL);
    return $.ajax(this.calendarURL, {
      type: "GET",
      dataType: "text",
      crossDomain: true,
      success: (function(_this) {
        return function(data, textStatus, jqXHR) {
          var jsonData, jsonText;
          jsonText = jqXHR.responseText;
          jsonData = $.parseJSON(jsonText);
          _this.showCalendar(jsonData);
          return console.log("CalShown");
        };
      })(this)
    });
  };

  CalendarTile.prototype.showCalendar = function(jsonData) {
    var calTitle, event, newHtml, newLine, reqDate, reqDateStr, _i, _len, _ref;
    if (!("calEvents" in jsonData)) {
      return;
    }
    newHtml = "";
    reqDate = new Date();
    reqDate.setDate(reqDate.getDate() + this.calDayIndex);
    reqDateStr = this.toZeroPadStr(reqDate.getFullYear(), 4) + this.toZeroPadStr(reqDate.getMonth() + 1, 2) + this.toZeroPadStr(reqDate.getDate(), 2);
    calTitle = "Today";
    if (this.calDayIndex !== 0) {
      calTitle = this.shortDayNames[reqDate.getDay()];
    }
    this.calLineCount = 0;
    this.calCharCount = 0;
    this.calMaxLineLen = 0;
    _ref = jsonData["calEvents"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      event = _ref[_i];
      if (event["eventDate"] === reqDateStr) {
        this.calLineCount += 1;
        newLine = "<span class=\"sqCalEventStart\">" + event["eventTime"] + "</span>\n<span class=\"sqCalEventDur\"> (" + (this.formatDurationStr(event["duration"])) + ") </span>\n<span class=\"sqCalEventSummary\">" + event["summary"] + "</span>";
        newHtml += "<li class=\"sqCalEvent\">\n	" + newLine + "\n</li>";
        this.calCharCount += newLine.length;
        this.calMaxLineLen = this.calMaxLineLen < newLine.length ? newLine.length : this.calMaxLineLen;
      }
    }
    this.contents.html("<div class=\"sqCalTitle\">" + calTitle + "</div>\n<ul class=\"sqCalEvents\">\n	" + newHtml + "\n</ul>");
    return this.recalculateFontScaling();
  };

  CalendarTile.prototype.toZeroPadStr = function(value, digits) {
    var s;
    s = "0000" + value;
    return s.substr(s.length - digits);
  };

  CalendarTile.prototype.reposition = function(posX, posY, sizeX, sizeY, fontScaling) {
    CalendarTile.__super__.reposition.call(this, posX, posY, sizeX, sizeY, fontScaling);
    return this.recalculateFontScaling();
  };

  CalendarTile.prototype.recalculateFontScaling = function() {
    var availHeight, calText, i, sizeInc, startScale, textHeight, _i;
    if ((this.sizeY == null) || (this.calLineCount === 0)) {
      return;
    }
    calText = this.getElement(".sqCalEvents");
    textHeight = calText.height();
    if (textHeight == null) {
      return;
    }
    availHeight = this.sizeY * 0.9;
    startScale = availHeight / textHeight;
    this.setContentFontScaling(startScale);
    sizeInc = 1.0;
    for (i = _i = 0; _i <= 6; i = ++_i) {
      calText = this.getElement(".sqCalEvents");
      textHeight = calText.height();
      if (textHeight == null) {
        return;
      }
      if (textHeight > availHeight) {
        startScale = startScale * (1 - (sizeInc / 2));
        this.setContentFontScaling(startScale);
      } else if (textHeight < (availHeight * 0.75)) {
        startScale = startScale * (1 + sizeInc);
        this.setContentFontScaling(startScale);
      } else {
        break;
      }
      sizeInc *= 0.5;
    }
  };

  CalendarTile.prototype.formatDurationStr = function(val) {
    var days, dur, hrs, mins, outStr;
    dur = val.split(":");
    days = parseInt(dur[0]);
    hrs = parseInt(dur[1]);
    mins = parseInt(dur[2]);
    outStr = "";
    if (days === 0 && hrs !== 0 && mins === 30) {
      outStr = (hrs + 0.5) + "h";
    } else {
      outStr = days === 0 ? "" : days + "d";
      outStr += hrs === 0 ? "" : hrs + "h";
      outStr += mins === 0 ? "" : mins + "m";
    }
    return outStr;
  };

  return CalendarTile;

})(Tile);

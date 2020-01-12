(function() {
  App.CalendarTile = class CalendarTile extends App.Tile {
    constructor(app, tileDef, calDayIndex) {
      super(tileDef);
      this.app = app;
      this.calDayIndex = calDayIndex;
      this.shortDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      this.calLineCount = 0;
      this.calCharCount = 0;
      this.calMaxLineLen = 0;
      this.secsBetweenCalendarRefreshes = 60;
      return;
    }

    handleAction(action) {
      if (action === "next") {
        if (this.calDayIndex < this.app.calendarManager.getCalNumDays()) {
          this.calDayIndex++;
        }
      } else if (action === "prev") {
        if (this.calDayIndex > 0) {
          this.calDayIndex--;
        }
      }
      this.updateCalendar();
    }

    addToDoc() {
      super.addToDoc();
      this.setRefreshInterval(this.secsBetweenCalendarRefreshes, this.updateCalendar, true);
    }

    updateCalendar() {
      var calData;
      calData = this.app.calendarManager.getCalData();
      return this.showCalendar(calData);
    }

    showCalendar(jsonData) {
      var calTitle, event, j, len, newHtml, newLine, ref, reqDate, reqDateStr;
      if (!("calEvents" in jsonData)) {
        return;
      }
      newHtml = "";
      // Calendar boxes can be for each of the next few days so see which date this one is for
      reqDate = new Date();
      reqDate.setDate(reqDate.getDate() + this.calDayIndex);
      reqDateStr = this.toZeroPadStr(reqDate.getFullYear(), 4) + this.toZeroPadStr(reqDate.getMonth() + 1, 2) + this.toZeroPadStr(reqDate.getDate(), 2);
      calTitle = "";
      if (this.calDayIndex === 0) {
        calTitle = "Today ";
      }
      calTitle += this.shortDayNames[reqDate.getDay()];
      calTitle += " " + this.toZeroPadStr(reqDate.getDate(), 2) + "/" + this.toZeroPadStr(reqDate.getMonth() + 1, 2) + "/" + this.toZeroPadStr(reqDate.getFullYear(), 4);
      // Format the text to go into the calendar and keep stats on it for font sizing
      this.calLineCount = 0;
      this.calCharCount = 0;
      this.calMaxLineLen = 0;
      ref = jsonData["calEvents"];
      for (j = 0, len = ref.length; j < len; j++) {
        event = ref[j];
        if (event["eventDate"] === reqDateStr) {
          this.calLineCount += 1;
          newLine = `<span class="sqCalEventStart">${event["eventTime"]}</span>\n<span class="sqCalEventDur"> (${this.formatDurationStr(event["duration"])}) </span>\n<span class="sqCalEventSummary">${event["summary"]}</span>`;
          newHtml += `<li class="sqCalEvent">\n	${newLine}\n</li>`;
          this.calCharCount += newLine.length;
          this.calMaxLineLen = this.calMaxLineLen < newLine.length ? newLine.length : this.calMaxLineLen;
        }
      }
      // Check for non-busy day
      if (newHtml === "") {
        newHtml = "Nothing doing";
      }
      // Place the calendar text
      this.contents.html(`<div class="sqCalTitle" style="font-size:26px;font-weight:bold;color:white;">${calTitle}</div>\n<ul class="sqCalEvents">\n	${newHtml}\n</ul>`);
      // Calculate optimal font size
      this.recalculateFontScaling();
    }

    // Utility function for leading zeroes
    toZeroPadStr(value, digits) {
      var s;
      s = "0000" + value;
      return s.substr(s.length - digits);
    }

    // Override reposition to handle font scaling
    reposition(posX, posY, sizeX, sizeY) {
      super.reposition(posX, posY, sizeX, sizeY);
      this.recalculateFontScaling();
    }

    // Calculate width of text from DOM element or string. By Phil Freo <http://philfreo.com>
    // This works but doesn't do what I want - which is to calculate the actual width of text
    // including overflowed text in a box of fixed width - what it does is removes the box width
    // restriction and calculates the overall width of the text at the given font size - useful
    // in some situations but not what I need
    calcTextWidth(text, fontSize, boxWidth) {
      if (this.fakeEl == null) {
        this.fakeEl = $("<span>").hide().appendTo(document.body);
      }
      this.fakeEl.text(text).css("font-size", fontSize);
      return this.fakeEl.width();
    }

    findOptimumFontSize(optHeight, docElem, initScale, maxFontScale) {
      var availSize, calText, fontScale, i, j, sizeInc, textSize;
      availSize = (optHeight ? this.sizeY : this.sizeX) * 0.9;
      calText = this.getElement(docElem);
      // console.log @calcTextWidth(calText.text(), calText.css("font-size"))
      textSize = optHeight ? calText.height() : this.calcTextWidth(calText.text(), calText.css("font-size"));
      if (textSize == null) {
        return 1.0;
      }
      fontScale = optHeight ? availSize / textSize : initScale;
      fontScale = fontScale > maxFontScale ? maxFontScale : fontScale;
      this.setContentFontScaling(fontScale);
      sizeInc = 1.0;
// Iterate through possible sizes in a kind of binary tree search
      for (i = j = 0; j <= 6; i = ++j) {
        calText = this.getElement(docElem);
        textSize = optHeight ? calText.height() : this.calcTextWidth(calText.text(), calText.css("font-size"));
        if (textSize == null) {
          return fontScale;
        }
        if (textSize > availSize) {
          fontScale = fontScale * (1 - (sizeInc / 2));
          this.setContentFontScaling(fontScale);
        } else if (textSize < (availSize * 0.75) && fontScale < maxFontScale) {
          fontScale = fontScale * (1 + sizeInc);
          this.setContentFontScaling(fontScale);
        } else {
          break;
        }
        sizeInc *= 0.5;
      }
      return fontScale;
    }

    // Provide a different font scaling based on the amount of text in the calendar box
    recalculateFontScaling() {
      var fontScale;
      if ((this.sizeX == null) || (this.sizeY == null) || (this.calLineCount === 0)) {
        return;
      }
      fontScale = this.findOptimumFontSize(true, ".sqCalEvents", 1.0, 2.2);
      //fontScale = @findOptimumFontSize(false, ".sqCalEvents", yScale)
      this.setContentFontScaling(fontScale);
    }

    setContentFontScaling(contentFontScaling) {
      var css;
      css = {
        "font-size": (100 * contentFontScaling) + "%"
      };
      $(".sqCalEvents").css(css);
    }

    formatDurationStr(val) {
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
    }

  };

}).call(this);


//# sourceMappingURL=calendar-tile.js.map
//# sourceURL=coffeescript
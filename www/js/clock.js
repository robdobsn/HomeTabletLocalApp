(function() {
  App.Clock = class Clock extends App.Tile {
    constructor(tileDef) {
      super(tileDef);
      this.dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
      this.shortDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      this.monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      this.shortMonthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return;
    }

    addToDoc() {
      super.addToDoc();
      this.contents.append("<div class=\"sqClockDow\" style=\"text-align:center\"></div>\n<div class=\"sqClockDayMonthYear\" style=\"text-align:center\"></div>\n<div class=\"sqClockTime\" style=\"display:block;text-align:center\">\n	<span class=\"sqClockHours\" style=\"padding:5px\"></span>\n	<span class=\"sqClockMins\"></span>\n	<span class=\"sqClockSecs\" style=\"display:inline;font-size:20%;position:absolute;\"></span>\n</div>\n<span class=\"sqClockPoint1\" \n		style=\"position:absolute;\n		       -moz-animation: mymove 1s ease infinite;\n		       -webkit-animation: mymove 1s ease infinite;\">:\n</span> ");
      this.updateClock();
      this.setRefreshInterval(1, this.updateClock, false);
    }

    reposition(posX, posY, sizeX, sizeY) {
      var timePos, timeTextHeight;
      this.posX = posX;
      this.posY = posY;
      this.sizeX = sizeX;
      this.sizeY = sizeY;
      super.reposition(this.posX, this.posY, this.sizeX, this.sizeY);
      timePos = this.sizeY / 3;
      $('#' + this.tileId + " .sqClockDayMonthYear").css({
        position: "absolute",
        fontSize: (this.sizeY / 5.5) + "px",
        top: (this.sizeY / 10) + "px",
        width: "100%"
      });
      $('#' + this.tileId + " .sqClockTime").css({
        position: "absolute",
        fontSize: (this.sizeY / 2) + "px",
        top: timePos + "px",
        left: "-7px",
        width: "100%"
      });
      timeTextHeight = $('#' + this.tileId + " .sqClockTime").height();
      $('#' + this.tileId + " .sqClockPoint1").css({
        position: "absolute",
        left: (this.sizeX / 2 - 12) + "px",
        top: (timePos + (timeTextHeight / 5)) + "px",
        fontSize: (this.sizeY / 3.5) + "px"
      });
    }

    updateClock() {
      var dt;
      dt = new Date();
      $('#' + this.tileId + " .sqClockDayMonthYear").html(this.shortDayNames[dt.getDay()] + " " + dt.getDate() + " " + this.shortMonthNames[dt.getMonth()] + " " + dt.getFullYear());
      $('#' + this.tileId + " .sqClockHours").html((dt.getHours() < 10 ? "0" : "") + dt.getHours());
      $('#' + this.tileId + " .sqClockMins").html((dt.getMinutes() < 10 ? "0" : "") + dt.getMinutes());
      $('#' + this.tileId + " .sqClockSecs").html((dt.getSeconds() < 10 ? "0" : "") + dt.getSeconds());
    }

  };

}).call(this);


//# sourceMappingURL=clock.js.map
//# sourceURL=coffeescript
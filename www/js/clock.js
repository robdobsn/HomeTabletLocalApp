// Generated by CoffeeScript 2.7.0
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
      this.contents.append(`<div class="sqClockDow" style="text-align:center"></div>
<div class="sqClockDayMonthYear" style="text-align:center"></div>
<div class="sqClockTime" style="display:block;text-align:center">
	<span class="sqClockHours" style="padding:5px"></span>
	<span class="sqClockMins"></span>
	<span class="sqClockSecs" style="display:inline;font-size:20%;position:absolute;"></span>
</div>
<span class="sqClockPoint1" 
		style="position:absolute;
		       -moz-animation: mymove 1s ease infinite;
		       -webkit-animation: mymove 1s ease infinite;">:
</span> `);
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
        fontSize: (this.sizeY / 6) + "px",
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
    }

  };

  // $('#'+@tileId+" .sqClockSecs").html (if dt.getSeconds() < 10 then "0" else "") + dt.getSeconds()

}).call(this);

//# sourceMappingURL=clock.js.map

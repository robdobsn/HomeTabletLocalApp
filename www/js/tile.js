// Generated by CoffeeScript 1.6.3
var Tile;

Tile = (function() {
  function Tile(tileBasics) {
    this.tileBasics = tileBasics;
    this.contentFontScaling = 1;
    this.pressStarted = 0;
  }

  Tile.prototype.addToDoc = function() {
    this.tileId = "sqTile_" + this.tileBasics.tierIdx + "_" + this.tileBasics.groupIdx + "_" + this.tileIdx;
    $(this.tileBasics.parentTag).append("<a class=\"sqTile\" id=\"" + this.tileId + "\" \n		href=\"javascript:void(0);\" \n		style=\"background-color:" + this.tileBasics.bkColour + ";\n				display:block; opacity:1;\">\n  <div class=\"sqInner\">\n  </div>\n</a>");
    this.addClickHandling();
    this.contents = $("#" + this.tileId + ">.sqInner");
    if (this.tileBasics.tierIdx === 0) {
      return $("#" + this.tileId).draggable({
        cancel: "a.ui-icon",
        revert: "invalid",
        containment: "document",
        helper: "clone",
        cursor: "move"
      });
    }
  };

  Tile.prototype.addClickHandling = function() {
    var dragDistMovedTest, longPressTime,
      _this = this;
    longPressTime = 1500;
    dragDistMovedTest = 20;
    $("#" + this.tileId).on("mousedown", function(e) {
      e.preventDefault();
      _this.pressStarted = new Date().getTime();
      _this.startDragXPos = e.pageX;
      _this.startDragYPos = e.pageY;
      return console.log("mousedown " + _this.startDragXPos + " " + _this.startDragYPos);
    });
    $("#" + this.tileId).on("touchstart", function(e) {
      var touchEvent;
      e.preventDefault();
      _this.pressStarted = new Date().getTime();
      touchEvent = e.originalEvent.touches[0];
      _this.startDragXPos = touchEvent.pageX;
      _this.startDragYPos = touchEvent.pageY;
      return console.log("touchdown " + _this.startDragXPos + " " + _this.startDragYPos);
    });
    $("#" + this.tileId).on("mouseleave", function() {
      return _this.pressStarted = 0;
    });
    $("#" + this.tileId).on("mousemove", function(e) {
      var curX, curY, distMoved;
      if (_this.pressStarted === 0) {
        return;
      }
      curX = e.pageX;
      curY = e.pageY;
      distMoved = _this.distMoved(curX, curY);
      if (distMoved > dragDistMovedTest) {
        $(_this).trigger(e);
      }
      return console.log("mousemove " + curX + " " + curY + " " + distMoved);
    });
    $("#" + this.tileId).on("touchmove", function(e) {
      var curX, curY, distMoved, touchEvent;
      if (_this.pressStarted === 0) {
        return;
      }
      e.preventDefault();
      _this.pressStarted = new Date().getTime();
      touchEvent = e.originalEvent.touches[0];
      curX = touchEvent.pageX;
      curY = touchEvent.psageY;
      distMoved = _this.distMoved(curX, curY);
      if (distMoved > dragDistMovedTest) {
        $(_this).trigger(e);
      }
      return console.log("mousemove " + curX + " " + curY + " " + distMoved);
    });
    return $("#" + this.tileId).on("mouseup touchend", function() {
      return _this.pressStarted = 0;
    });
  };

  Tile.prototype.distMoved = function(x, y) {
    var dist, xSep, ySep;
    xSep = this.startDragXPos - x;
    ySep = this.startDragYPos - y;
    return dist = Math.sqrt(xSep * xSep + ySep * ySep);
  };

  Tile.prototype.playClickSound = function() {
    if (window.soundClick != null) {
      return window.soundClick.play();
    }
  };

  Tile.prototype.removeFromDoc = function() {
    if (this.refreshId != null) {
      clearInterval(this.refreshId);
    }
    return $('#' + this.tileId).remove();
  };

  Tile.prototype.setTileIndex = function(tileIdx) {
    this.tileIdx = tileIdx;
  };

  Tile.prototype.reposition = function(posX, posY, sizeX, sizeY, fontScaling) {
    this.posX = posX;
    this.posY = posY;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.fontScaling = fontScaling;
    return this.setPositionCss(this.posX, this.posY, this.sizeX, this.sizeY, this.fontScaling);
  };

  Tile.prototype.setPositionCss = function(posX, posY, sizeX, sizeY, fontScaling) {
    return $('#' + this.tileId).css({
      "margin-left": posX + "px",
      "margin-top": posY + "px",
      "width": sizeX + "px",
      "height": sizeY + "px",
      "font-size": (fontScaling * this.contentFontScaling) + "%",
      "display": "block"
    });
  };

  Tile.prototype.setContentFontScaling = function(contentFontScaling) {
    this.contentFontScaling = contentFontScaling;
    return this.setPositionCss(this.posX, this.posY, this.sizeX, this.sizeY, this.fontScaling);
  };

  Tile.prototype.getElement = function(element) {
    return $('#' + this.tileId + " " + element);
  };

  Tile.prototype.isVisible = function(isPortrait) {
    if (this.tileBasics.visibility === "all") {
      return true;
    }
    if (this.tileBasics.visibility === "portrait" && isPortrait) {
      return true;
    }
    if (this.tileBasics.visibility === "landscape" && (!isPortrait)) {
      return true;
    }
    return false;
  };

  Tile.prototype.setInvisible = function() {
    return $('#' + this.tileId).css({
      "display": "none"
    });
  };

  Tile.prototype.setRefreshInterval = function(intervalInSecs, callbackFn, firstCallNow) {
    var _this = this;
    this.callbackFn = callbackFn;
    if (firstCallNow) {
      this.callbackFn();
    }
    return this.refreshId = setInterval(function() {
      return _this.callbackFn();
    }, intervalInSecs * 1000);
  };

  return Tile;

})();

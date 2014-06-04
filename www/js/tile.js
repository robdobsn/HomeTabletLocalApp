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
    return this.contents = $("#" + this.tileId + ">.sqInner");
  };

  Tile.prototype.addClickHandling = function() {
    var longPressTime,
      _this = this;
    longPressTime = 1500;
    $("#" + this.tileId).on("mousedown", function(e) {
      e.preventDefault();
      _this.pressStarted = new Date().getTime();
      _this.touchXPos = e.pageX;
      return _this.touchYPos = e.pageY;
    });
    $("#" + this.tileId).on("touchstart", function(e) {
      var touchEvent;
      e.preventDefault();
      _this.pressStarted = new Date().getTime();
      touchEvent = e.originalEvent.touches[0];
      _this.touchXPos = touchEvent.pageX;
      return _this.touchYPos = touchEvent.pageY;
    });
    return $("#" + this.tileId).on("mouseup touchend", function() {
      if (new Date().getTime() >= _this.pressStarted + longPressTime) {
        alert("Long press");
      } else {
        _this.tileBasics.mediaPlayHelper.play("click");
        _this.tileBasics.clickFn(_this.tileBasics.clickParam);
      }
      return _this.pressStarted = 0;
    });
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

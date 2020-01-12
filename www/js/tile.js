(function() {
  App.Tile = class Tile {
    constructor(tileDef) {
      this.tileDef = tileDef;
      return;
    }

    handleAction(action) {
      return console.log("Action = " + action);
    }

    addToDoc() {
      this.tileId = "sqTile_" + this.tileDef.tierIdx + "_" + this.tileDef.groupIdx + "_" + this.tileIdx;
      $(this.tileDef.parentTag).append(`<a class="sqTile" id="${this.tileId}" \n		href="javascript:void(0);" \n		style="background-color:${this.tileDef.tileColour};\n				display:block; opacity:1;">\n  <div class="sqInner" style="height:100%">\n  </div>\n</a>`);
      if ((this.tileDef.clickFn != null) && this.tileDef.clickFn !== "") {
        $(`#${this.tileId}`).click((event) => {
          event.stopPropagation();
          this.tileDef.clickFn(this.tileDef);
          return false;
        });
      }
      this.contents = $(`#${this.tileId}>.sqInner`);
    }

    distMoved(x1, y1, x2, y2) {
      var dist, xSep, ySep;
      xSep = x1 - x2;
      ySep = y1 - y2;
      dist = Math.sqrt((xSep * xSep) + (ySep * ySep));
      return dist;
    }

    removeFromDoc() {
      if (this.refreshId != null) {
        clearInterval(this.refreshId);
      }
      $('#' + this.tileId).remove();
    }

    setTileIndex(tileIdx) {
      this.tileIdx = tileIdx;
    }

    reposition(posX1, posY1, sizeX1, sizeY1) {
      this.posX = posX1;
      this.posY = posY1;
      this.sizeX = sizeX1;
      this.sizeY = sizeY1;
      this.setPositionCss('#' + this.tileId, this.posX, this.posY, this.sizeX, this.sizeY);
    }

    setPositionCss(selector, posX, posY, sizeX, sizeY) {
      var css;
      css = {
        "margin-left": posX + "px",
        "margin-top": posY + "px"
      };
      if (sizeX != null) {
        css["width"] = sizeX + "px";
      }
      if (sizeY != null) {
        css["height"] = sizeY + "px";
      }
      $(selector).css(css);
    }

    getElement(element) {
      return $('#' + this.tileId + " " + element);
    }

    isVisible(isPortrait) {
      if (this.tileDef.visibility === "all") {
        return true;
      }
      if (this.tileDef.visibility === "portrait" && isPortrait) {
        return true;
      }
      if (this.tileDef.visibility === "landscape" && (!isPortrait)) {
        return true;
      }
      return false;
    }

    setInvisible() {
      $('#' + this.tileId).css({
        "display": "none"
      });
    }

    setRefreshInterval(intervalInSecs, callbackFn, firstCallNow) {
      this.callbackFn = callbackFn;
      if (firstCallNow) {
        this.callbackFn();
      }
      this.refreshId = setInterval(() => {
        return this.callbackFn();
      }, intervalInSecs * 1000);
    }

  };

}).call(this);


//# sourceMappingURL=tile.js.map
//# sourceURL=coffeescript
(function() {
  App.TilePosition = class TilePosition {
    constructor(tileValid, xPos = 0, yPos = 0, colSpan = 0, rowSpan = 0) {
      this.tileValid = tileValid;
      this.xPos = xPos;
      this.yPos = yPos;
      this.colSpan = colSpan;
      this.rowSpan = rowSpan;
      return;
    }

    intersects(tilePos) {
      if (!this.tileValid) {
        return false;
      }
      if (this.xPos > tilePos.xPos + tilePos.colSpan - 1) {
        return false;
      }
      if (this.xPos + this.colSpan - 1 < tilePos.xPos) {
        return false;
      }
      if (this.yPos > tilePos.yPos + tilePos.rowSpan - 1) {
        return false;
      }
      if (this.yPos + this.rowSpan - 1 < tilePos.yPos) {
        return false;
      }
      return true;
    }

  };

}).call(this);


//# sourceMappingURL=tile-basics.js.map
//# sourceURL=coffeescript
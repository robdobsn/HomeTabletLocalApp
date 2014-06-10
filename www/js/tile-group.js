// Generated by CoffeeScript 1.6.3
var TileGroup;

TileGroup = (function() {
  function TileGroup(tileTier, groupTitlesTag, groupIdx, groupTitle) {
    this.tileTier = tileTier;
    this.groupTitlesTag = groupTitlesTag;
    this.groupIdx = groupIdx;
    this.groupTitle = groupTitle;
    this.tiles = [];
    this.tilePositions = [];
    this.groupIdTag = "sqGroupTitle" + groupIdx;
    $(groupTitlesTag).append("<div class=\"sqGroupTitle " + this.groupIdTag + "\">" + this.groupTitle + "\n</div>");
  }

  TileGroup.prototype.clearTiles = function() {
    var tile, _i, _len, _ref;
    _ref = this.tiles;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tile = _ref[_i];
      tile.removeFromDoc();
    }
    return this.tiles = [];
  };

  TileGroup.prototype.numTiles = function() {
    return this.tiles.length;
  };

  TileGroup.prototype.findBestPlaceForTile = function(colSpan, rowSpan, tilesDown, tilesAcross) {
    var bestColIdx, bestRowIdx, colIdx, posValid, rowIdx, tilePos, _i, _j, _k, _len, _ref, _ref1, _ref2;
    bestColIdx = 0;
    bestRowIdx = 0;
    for (rowIdx = _i = 0, _ref = tilesDown - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; rowIdx = 0 <= _ref ? ++_i : --_i) {
      for (colIdx = _j = 0, _ref1 = tilesAcross - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; colIdx = 0 <= _ref1 ? ++_j : --_j) {
        if ((colIdx + colSpan) > tilesAcross) {
          continue;
        }
        posValid = true;
        _ref2 = this.tilePositions;
        for (_k = 0, _len = _ref2.length; _k < _len; _k++) {
          tilePos = _ref2[_k];
          if (tilePos.intersects(new TilePosition(true, colIdx, rowIdx, colSpan, rowSpan))) {
            posValid = false;
            break;
          }
        }
        if (posValid) {
          bestColIdx = colIdx;
          bestRowIdx = rowIdx;
          break;
        }
      }
      if (posValid) {
        break;
      }
    }
    if (!posValid) {
      return new TilePosition(false);
    }
    return new TilePosition(true, bestColIdx, bestRowIdx, colSpan, rowSpan);
  };

  TileGroup.prototype.getColsInGroup = function(tilesDown, isPortrait) {
    var cellCount, estColCount, maxColSpan, tile, tileIdx, _i, _j, _len, _len1, _ref, _ref1;
    this.tiles.sort(this.sortByTileWidth);
    this.tilePositions = [];
    cellCount = 0;
    maxColSpan = 1;
    _ref = this.tiles;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tile = _ref[_i];
      if (tile.isVisible(isPortrait)) {
        cellCount += tile.tileBasics.colSpan * tile.tileBasics.rowSpan;
        maxColSpan = Math.max(maxColSpan, tile.tileBasics.colSpan);
      }
    }
    estColCount = Math.floor((cellCount + tilesDown - 1) / tilesDown);
    estColCount = Math.max(estColCount, maxColSpan);
    _ref1 = this.tiles;
    for (tileIdx = _j = 0, _len1 = _ref1.length; _j < _len1; tileIdx = ++_j) {
      tile = _ref1[tileIdx];
      if (tile.isVisible(isPortrait)) {
        this.tilePositions.push(this.findBestPlaceForTile(tile.tileBasics.colSpan, tile.tileBasics.rowSpan, tilesDown, estColCount));
      } else {
        this.tilePositions.push(new TilePosition(false));
      }
    }
    return estColCount;
  };

  TileGroup.prototype.addExistingTile = function(tile) {
    tile.setTileIndex(this.tileTier.getNextTileIdx());
    tile.addToDoc();
    return this.tiles.push(tile);
  };

  TileGroup.prototype.sortByTileWidth = function(a, b) {
    if (a.tileBasics.colSpan === b.tileBasics.colSpan) {
      return a.tileIdx - b.tileIdx;
    }
    return a.tileBasics.colSpan - b.tileBasics.colSpan;
  };

  TileGroup.prototype.repositionTiles = function(isPortrait) {
    var fontScaling, fontSize, tile, tileHeight, tileIdx, tileWidth, titleX, titleY, xPos, yPos, _i, _len, _ref, _ref1, _ref2, _ref3, _results;
    _ref = this.tileTier.getGroupTitlePos(this.groupIdx), titleX = _ref[0], titleY = _ref[1], fontSize = _ref[2];
    $(this.groupTitlesTag + " ." + this.groupIdTag).css({
      "margin-left": titleX + "px",
      "margin-top": titleY + "px",
      "font-size": fontSize
    });
    _ref1 = this.tiles;
    _results = [];
    for (tileIdx = _i = 0, _len = _ref1.length; _i < _len; tileIdx = ++_i) {
      tile = _ref1[tileIdx];
      if (this.tilePositions[tileIdx].tileValid) {
        _ref2 = this.tileTier.getTileSize(tile.tileBasics.colSpan, tile.tileBasics.rowSpan), tileWidth = _ref2[0], tileHeight = _ref2[1];
        _ref3 = this.tileTier.getCellPos(this.groupIdx, this.tilePositions[tileIdx].xPos, this.tilePositions[tileIdx].yPos), xPos = _ref3[0], yPos = _ref3[1], fontScaling = _ref3[2];
        _results.push(tile.reposition(xPos, yPos, tileWidth, tileHeight, fontScaling));
      } else {
        _results.push(tile.setInvisible());
      }
    }
    return _results;
  };

  TileGroup.prototype.findExistingTile = function(tileName) {
    var existingTile, tile, _i, _len, _ref;
    existingTile = null;
    _ref = this.tiles;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tile = _ref[_i];
      if (tile.tileBasics.tileName === tileName) {
        existingTile = tile;
        break;
      }
    }
    return existingTile;
  };

  return TileGroup;

})();

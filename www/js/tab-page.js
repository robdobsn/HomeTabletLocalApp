(function() {
  App.TabPage = class TabPage {
    constructor(app, parentTag, pageDef, defaultActionFn) {
      this.app = app;
      this.parentTag = parentTag;
      this.pageDef = pageDef;
      this.defaultActionFn = defaultActionFn;
      this.tiles = [];
      this.titlesTopMargin = 60;
      this.titlesYPos = 10;
      this.pageBorders = [12, 5, 12, 15];
      this.tileSepXPixels = 20;
      this.tileSepYPixels = 10;
      this.groupSepPixels = 10;
      this.pageId = "sqPage";
      this.pageSelector = "#" + this.pageId;
      this.pageTitleClass = "sqPageTitle";
      this.pageTitleSelector = "." + this.pageTitleClass;
      this.tilesClass = "sqTiles";
      this.tileContainerClass = "sqTileContainer";
      this.tilesSelector = '.' + this.tileContainerClass;
      this.colTitleClass = "sqColTitle";
      this.tilesColumns = 2; // Overridden in redolayout
      this.nextTileIdx = 0;
      this.columnTypes = {};
      return;
    }

    handlePageNav(pageNav) {
      var _, j, len, navAction, ref, tile, tileName;
      [_, tileName, navAction] = pageNav.match(/\~(.*)\?(.*)/);
      ref = this.tiles;
      for (j = 0, len = ref.length; j < len; j++) {
        tile = ref[j];
        if (tile.tileDef.tileName === tileName) {
          tile.handleAction(navAction);
          break;
        }
      }
    }

    updateDom() {
      var col, colIdx, colXPos, j, k, len, len1, newTile, ref, ref1, sizeX, sizeY, tile, tileDef, title, x, y;
      this.calcLayout();
      this.removeAll();
      // Add to html in parent tag
      $(this.parentTag).html(`<div id="${this.pageId}" class="sqPage">\n	<div class="${this.pageTitleClass}"/>\n	<div class="${this.tilesClass}" style="height:100%;width:100%">\n		<div class=${this.tileContainerClass} style="width:100%;display:block;zoom:1;">\n		</div>\n	</div>\n</div>`);
      // Titles
      if (this.columnsDef != null) {
        ref = this.columnsDef;
        for (colIdx = j = 0, len = ref.length; j < len; colIdx = ++j) {
          col = ref[colIdx];
          title = col.title;
          if ((title != null) && title !== "") {
            $(this.pageTitleSelector).append(`<div class="${this.colTitleClass} ${this.colTitleClass}_${colIdx}">${title}\n</div>`);
          }
          colXPos = this.getColXPos(colIdx);
          this.setTitlePositionCss(colIdx, colXPos, this.titlesYPos, 100);
        }
      }
      // Tiles
      if (this.pageDef.tiles != null) {
        ref1 = this.pageDef.tiles;
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          tileDef = ref1[k];
          newTile = this.makeTileFromTileDef(tileDef);
          tile = this.addTileToPage(tileDef, newTile);
          [x, y, sizeX, sizeY] = this.getCellPos(tile);
          tile.reposition(x, y, sizeX, sizeY);
        }
      }
    }

    removeAll() {
      this.nextTileIdx = 0;
      this.clearTiles();
      $(`#${this.pageId}`).remove();
    }

    clearTiles() {
      var j, len, ref, tile;
      ref = this.tiles;
      for (j = 0, len = ref.length; j < len; j++) {
        tile = ref[j];
        tile.removeFromDoc();
      }
      this.tiles = [];
    }

    addTileToPage(tileDef, tile) {
      tile.addToDoc();
      this.tiles.push(tile);
      return tile;
    }

    makeTileFromTileDef(tileDef) {
      var dayIdx, tile;
      // Ensure tileDef is clean
      tileDef = this.tileDefCleanCheck(tileDef);
      //Make the tile
      if (tileDef.tileType === "calendar") {
        dayIdx = tileDef.calDayIndex != null ? tileDef.calDayIndex : 0;
        tile = new App.CalendarTile(this.app, tileDef, dayIdx);
      } else if (tileDef.tileType === "clock") {
        tile = new App.Clock(tileDef);
      } else if (tileDef.tileType === "iframe") {
        tile = new App.IframeTile(tileDef);
      } else if (tileDef.tileType === "checkbox") {
        tile = new App.CheckBoxTile(tileDef);
      } else if (tileDef.tileType === "textentry") {
        tile = new App.TextEntryTile(tileDef);
      } else {
        tile = new App.SceneButton(tileDef);
      }
      tile.setTileIndex(this.nextTileIdx++);
      return tile;
    }

    tileDefCleanCheck(tileDef) {
      tileDef.parentTag = this.tilesSelector;
      if (!("tileColour" in tileDef)) {
        tileDef.tileColour = this.app.tileColours.getNextColour();
      }
      if (!("clickFn" in tileDef)) {
        tileDef.clickFn = this.defaultActionFn;
      }
      if (!("colSpan" in tileDef)) {
        tileDef.colSpan = 1;
      }
      if (!("rowSpan" in tileDef)) {
        tileDef.rowSpan = 1;
      }
      if (!("url" in tileDef)) {
        tileDef.url = "";
      }
      if (!("visibility" in tileDef)) {
        tileDef.visibility = "both";
      }
      if (!("tileName" in tileDef)) {
        tileDef.tileName = "";
      }
      if (!("tileText" in tileDef)) {
        tileDef.tileText = "";
      }
      if (!("iconName" in tileDef)) {
        tileDef.iconName = "";
      }
      if (!("positionCue" in tileDef)) {
        tileDef.positionCue = "";
      }
      tileDef.tierIdx = 0;
      tileDef.groupIdx = 0;
      return tileDef;
    }

    getPageHeight() {
      var pageSel;
      pageSel = $(`#${this.pageId}`);
      return pageSel[0].clientHeight;
    }

    getPageTop() {
      return 0;
    }

    calcLayout() {
      var autoAddColIdx, col, colDef, colIdx, colToCopy, colType, colsToAdd, i, isPortrait, j, k, l, len, len1, len2, m, numTilesInAutoCol, ref, ref1, ref2, ref3, tile, winHeight, winWidth;
      winWidth = $(window).width();
      winHeight = $(window).height();
      isPortrait = winWidth < winHeight;
      if (isPortrait) {
        this.baseColumnsDef = this.pageDef.columns != null ? this.pageDef.columns.portrait : null;
        this.tilesDown = this.pageDef.rows != null ? this.pageDef.rows.portrait : 15;
        this.tilesAcross = 2;
        this.columnsAcross = 2;
      } else {
        this.baseColumnsDef = this.pageDef.columns != null ? this.pageDef.columns.landscape : null;
        this.tilesDown = this.pageDef.rows != null ? this.pageDef.rows.landscape : 8;
        this.tilesAcross = 3;
        this.columnsAcross = 3;
      }
      this.columnsDef = [];
      if (this.baseColumnsDef != null) {
        this.columnsDef = (function() {
          var j, len, ref, results;
          ref = this.baseColumnsDef;
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            col = ref[j];
            results.push(col);
          }
          return results;
        }).call(this);
      }
      this.noTitles = true;
      // Check for auto-add columns
      autoAddColIdx = -1;
      colsToAdd = 0;
      ref = this.columnsDef;
      for (colIdx = j = 0, len = ref.length; j < len; colIdx = ++j) {
        colDef = ref[colIdx];
        if ((colDef.autoAdd != null) && colDef.autoAdd) {
          autoAddColIdx = colIdx;
          numTilesInAutoCol = 0;
          ref1 = this.pageDef.tiles;
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            tile = ref1[k];
            if (!((tile.colType != null) && colDef.colType && (tile.colType !== colDef.colType))) {
              numTilesInAutoCol++;
            }
          }
          colsToAdd = Math.floor(numTilesInAutoCol / this.tilesDown + 0.5) - 2;
          break;
        }
      }
      if (colsToAdd > 0) {
        colToCopy = this.columnsDef[autoAddColIdx];
        for (i = l = 0, ref2 = colsToAdd; (0 <= ref2 ? l < ref2 : l > ref2); i = 0 <= ref2 ? ++l : --l) {
          this.columnsDef.splice(autoAddColIdx, 0, colToCopy);
        }
      }
      // Handle columns
      if (this.columnsDef != null) {
        this.tilesAcross = 0;
        ref3 = this.columnsDef;
        for (colIdx = m = 0, len2 = ref3.length; m < len2; colIdx = ++m) {
          colDef = ref3[colIdx];
          if ((colDef.title != null) && colDef.title !== "") {
            this.noTitles = false;
          }
          colType = colDef.colType != null ? colDef.colType : "";
          if (!(colType in this.columnTypes)) {
            this.columnTypes[colType] = {
              frontTileCount: 0,
              endTileCount: 0,
              colStartIdx: colIdx,
              colCount: 1,
              colSpan: colDef.colSpan != null ? colDef.colSpan : 1
            };
          } else {
            this.columnTypes[colType].colCount++;
            this.columnTypes[colType].colSpan += colDef.colSpan != null ? colDef.colSpan : 1;
          }
          this.tilesAcross += colDef.colSpan;
        }
        this.columnsAcross = this.columnsDef.length;
      } else {
        this.columnTypes = {
          "": {
            frontTileCount: 0,
            endTileCount: 0,
            colStartIdx: 0,
            colCount: 1
          }
        };
      }
      // Layout page
      this.cellWidth = (winWidth - this.pageBorders[1] - this.pageBorders[3]) / this.tilesAcross;
      this.cellHeight = (winHeight - this.pageBorders[0] - this.pageBorders[2] - (this.noTitles ? 0 : this.titlesTopMargin)) / this.tilesDown;
      this.tileWidth = this.cellWidth - this.tileSepXPixels;
      this.tileHeight = this.cellHeight - this.tileSepYPixels;
      $(`#${this.pageId}`).css({
        "height": document.documentElement.clientHeight + "px"
      });
      return isPortrait;
    }

    getColXPos(colIdx) {
      var cellX, cellXIdx, i, j, ref, xStart;
      xStart = this.pageBorders[3];
      // Default if no columns specified
      cellX = xStart + colIdx * this.cellWidth * 2;
      // Work out from column def
      cellXIdx = 0;
      for (i = j = 0, ref = colIdx; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
        cellXIdx += (this.columnsDef != null) && this.columnsDef[i] ? this.columnsDef[i].colSpan : 1;
      }
      return xStart + cellXIdx * this.cellWidth;
    }

    getTitlePos() {
      return [0, 10, "200%"];
    }

    getGroupTitleWidth() {
      return 400;
    }

    getColInfo(tile) {}

    getCellPos(tile) {
      var cellX, cellY, colIdx, colInfo, colSpan, colType, isPortrait, rowIdx, rowSpan, sizeX, sizeY, winHeight, winWidth;
      colType = tile.tileDef.colType != null ? tile.tileDef.colType : "";
      if (colType in this.columnTypes) {
        colInfo = this.columnTypes[colType];
      } else {
        colInfo = this.columnTypes[""];
      }
      // Check for colSpan not specified
      if (!("colSpan" in tile.tileDef) || tile.tileDef.colSpan === 0) {
        colSpan = colInfo.colSpan;
      } else {
        colSpan = tile.tileDef.colSpan;
      }
      // Check for rowSpan not specified
      if (!("rowSpan" in tile.tileDef) || tile.tileDef.rowSpan === 0) {
        rowSpan = this.tilesDown;
      } else {
        rowSpan = tile.tileDef.rowSpan;
      }
      // Check for special positioning cues
      if (tile.tileDef.positionCue === "end") {
        winWidth = $(window).width();
        winHeight = $(window).height();
        isPortrait = winWidth < winHeight;
        if (isPortrait) {
          colIdx = 1;
          colSpan = 1;
          rowIdx = this.tilesDown - Math.floor(colInfo.endTileCount % this.tilesDown) - rowSpan;
          colInfo.endTileCount += rowSpan;
        } else {
          colIdx = colInfo.colStartIdx + colInfo.colCount - 1 - Math.floor(colInfo.endTileCount / this.tilesDown);
          rowIdx = this.tilesDown - Math.floor(colInfo.endTileCount % this.tilesDown) - rowSpan;
          colInfo.endTileCount += rowSpan;
        }
      } else {
        colIdx = colInfo.colStartIdx + Math.floor(colInfo.frontTileCount / this.tilesDown);
        rowIdx = Math.floor(colInfo.frontTileCount % this.tilesDown);
        colInfo.frontTileCount += rowSpan;
      }
      // Column position
      cellX = this.getColXPos(colIdx);
      cellY = this.pageBorders[0] + (this.noTitles ? 0 : this.titlesTopMargin) + rowIdx * this.cellHeight;
      // Size of tile in pixels		
      sizeX = this.tileWidth * colSpan + (this.tileSepXPixels * (colSpan - 1));
      sizeY = this.tileHeight * rowSpan + (this.tileSepYPixels * (rowSpan - 1));
      return [cellX, cellY, sizeX, sizeY];
    }

    reDoLayout() {
      return this.calcLayout();
    }

    getTilesAcrossScreen() {
      return this.tilesAcross;
    }

    setTitlePositionCss(colIdx, posX, posY) {
      $('.' + this.colTitleClass + "_" + colIdx).css({
        "margin-left": posX + "px",
        "margin-top": posY + "px",
        "display": "block",
        "position": "absolute"
      });
    }

  };

  // "font-size": fontScaling + "%",

}).call(this);


//# sourceMappingURL=tab-page.js.map
//# sourceURL=coffeescript
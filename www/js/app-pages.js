(function() {
  var indexOf = [].indexOf;

  App.AppPages = class AppPages {
    constructor(app, parentTag, automationManager) {
      this.buttonCallback = this.buttonCallback.bind(this);
      this.app = app;
      this.parentTag = parentTag;
      this.automationManager = automationManager;
      this.curPageDef = {
        "pageName": ""
      };
      this.generatedPage = {};
      this.defaultPageName = "";
      this.curTabPage = null;
      // Basic body for DOM
      $("body").prepend("<div id=\"sqWrapper\">\n</div>");
    }

    userIsIdle() {
      var autoDim;
      // Check for auto-dim
      autoDim = App.LocalStorage.get("AutoDim");
      if ((autoDim != null) && autoDim) {
        if (this.setCurrentPage("DimDisplay")) {
          this.display();
          return;
        }
      }
      // Return to home page
      if (this.curPageDef.pageName !== this.defaultPageName) {
        this.setCurrentPage(this.defaultPageName);
        this.display();
      }
    }

    setCurrentPage(pageName, forceSet) {
      var tabConfig;
      tabConfig = this.app.tabletConfigManager.getConfigData();
      if ((tabConfig.common != null) && (tabConfig.common.pages != null)) {
        if (pageName in tabConfig.common.pages) {
          if (forceSet || (this.curPageDef.pageName !== pageName)) {
            this.curPageDef = tabConfig.common.pages[pageName];
            return true;
          }
        } else if (forceSet || ((this.generatedPage.pageName != null) && this.generatedPage.pageName === pageName)) {
          this.curPageDef = this.generatedPage;
          return true;
        }
      }
      return false;
    }

    build(automationActionGroups) {
      this.automationActionGroups = automationActionGroups;
      return this.rebuild(true);
    }

    rebuild(forceSetInitialPage) {
      var i, len, pageDef, pageName, ref, ref1, results, tabConfig, tile;
      // Generate pages from data
      tabConfig = this.app.tabletConfigManager.getConfigData();
      if ((tabConfig.common != null) && (tabConfig.common.pages != null)) {
        ref = tabConfig.common.pages;
        results = [];
        for (pageName in ref) {
          pageDef = ref[pageName];
          if ((pageDef.defaultPage != null) && pageDef.defaultPage) {
            if (forceSetInitialPage) {
              this.setCurrentPage(pageName, true);
            }
            this.defaultPageName = pageName;
          }
          pageDef.tiles = [];
          if (pageDef.tilesFixed != null) {
            ref1 = pageDef.tilesFixed;
            for (i = 0, len = ref1.length; i < len; i++) {
              tile = ref1[i];
              pageDef.tiles.push(tile);
            }
          }
          results.push(this.generatePageContents(pageDef, tabConfig));
        }
        return results;
      }
    }

    generatePageContents(pageDef, tabletSpecificConfig) {
      var favFound, favList, i, j, k, l, len, len1, len10, len11, len12, len2, len3, len4, len5, len6, len7, len8, len9, m, n, newTile, o, p, q, r, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, s, source, sourceList, t, tile, tileGen, tileList, tileSource, u, uniqList, val;
      tileList = [];
      uniqList = [];
      // Tile generators provide metadata to allow tiles to be constructed from
      // tilesources like indigo/fibaro/vera/sonos/blind/door controllers
      if (!("tileGen" in pageDef)) {
        return;
      }
      ref = pageDef.tileGen;
      // Go through tileGen requirements
      for (i = 0, len = ref.length; i < len; i++) {
        tileGen = ref[i];
        // Check if a specific tile source is specified - otherwise all sources are used
        sourceList = [];
        if ("tileSources" in tileGen) {
          sourceList = (function() {
            var j, len1, ref1, results;
            ref1 = tileGen.tileSources;
            results = [];
            for (j = 0, len1 = ref1.length; j < len1; j++) {
              source = ref1[j];
              if (source in this.automationActionGroups) {
                results.push(source);
              }
            }
            return results;
          }).call(this);
        } else {
          sourceList = (function() {
            var ref1, results;
            ref1 = this.automationActionGroups;
            results = [];
            for (source in ref1) {
              val = ref1[source];
              results.push(source);
            }
            return results;
          }).call(this);
        }
        // The tileMult "unique" is used to select a single tile from
        // a tile group - this is for creating menu listing rooms, etc
        if (tileGen.tileMult === "unique") {
// Iterate tiles in the tile sources
          for (j = 0, len1 = sourceList.length; j < len1; j++) {
            tileSource = sourceList[j];
            ref1 = this.automationActionGroups[tileSource];
            for (k = 0, len2 = ref1.length; k < len2; k++) {
              tile = ref1[k];
              if (tileGen.tileSelect in tile) {
                if (ref2 = tile[tileGen.tileSelect], indexOf.call(uniqList, ref2) < 0) {
                  newTile = this.generateTileInfo(tileGen, tile);
                  tileList.push(newTile);
                  uniqList.push(newTile[tileGen.tileSelect]);
                }
              }
            }
          }
        // Handle generation of pages for a specific group - e.g. a specific room menu
        } else if ("tileFilterValFrom" in tileGen) {
          for (l = 0, len3 = sourceList.length; l < len3; l++) {
            tileSource = sourceList[l];
            ref3 = this.automationActionGroups[tileSource];
            for (m = 0, len4 = ref3.length; m < len4; m++) {
              tile = ref3[m];
              if (tileGen.tileSelect in tile) {
                if (tile[tileGen.tileSelect] === pageDef[tileGen.tileFilterValFrom]) {
                  newTile = this.generateTileInfo(tileGen, tile);
                  tileList.push(newTile);
                }
              }
            }
          }
        // Select a single specific tile but using data from the tabled config
        // such as the favourites list - e.g. using the groupname (room) and
        // tilename (action) to get a favourite tile
        } else if ("tabConfigFavListName" in tileGen && tileGen.tabConfigFavListName in tabletSpecificConfig) {
          ref4 = tabletSpecificConfig[tileGen.tabConfigFavListName];
          for (n = 0, len5 = ref4.length; n < len5; n++) {
            favList = ref4[n];
            favFound = false;
            for (o = 0, len6 = sourceList.length; o < len6; o++) {
              tileSource = sourceList[o];
              ref5 = this.automationActionGroups[tileSource];
              for (p = 0, len7 = ref5.length; p < len7; p++) {
                tile = ref5[p];
                if (tileGen.tileSelect in tile) {
                  if (tile[tileGen.tileSelect] === favList[tileGen.tileSelect] && tile[tileGen.tileNameFrom] === favList.tileName) {
                    newTile = this.generateTileInfo(tileGen, tile);
                    if ("tileText" in favList) {
                      newTile.tileText = favList.tileText;
                    }
                    tileList.push(newTile);
                    favFound = true;
                    break;
                  }
                }
              }
              if (favFound) {
                break;
              }
            }
          }
        // Only select a single specific tile explicitly named in the pageDef
        // e.g. using the specific groupname (room) and tilename (action)
        } else if ("tileFilterVal" in tileGen) {
          for (q = 0, len8 = sourceList.length; q < len8; q++) {
            tileSource = sourceList[q];
            ref6 = this.automationActionGroups[tileSource];
            for (r = 0, len9 = ref6.length; r < len9; r++) {
              tile = ref6[r];
              if (tileGen.tileSelect in tile) {
                if (tile[tileGen.tileSelect] === tileGen.tileFilterVal) {
                  if ("tileNameSelect" in tileGen) {
                    if (tile[tileGenInfo.tileNameFrom] === tileGen.tileNameSelect) {
                      newTile = this.generateTileInfo(tileGen, tile);
                      tileList.push(newTile);
                    }
                  } else {
                    newTile = this.generateTileInfo(tileGen, tile);
                    tileList.push(newTile);
                  }
                }
              }
            }
          }
        } else {
          for (s = 0, len10 = sourceList.length; s < len10; s++) {
            tileSource = sourceList[s];
            ref7 = this.automationActionGroups[tileSource];
            for (t = 0, len11 = ref7.length; t < len11; t++) {
              tile = ref7[t];
              newTile = this.generateTileInfo(tileGen, tile);
              tileList.push(newTile);
            }
          }
        }
      }
      // Sort tiles if required
      if ("tileSort" in tileGen) {
        tileList.sort((a, b) => {
          if (a[tileGen.tileSort] < b[tileGen.tileSort]) {
            return -1;
          }
          if (a[tileGen.tileSort] > b[tileGen.tileSort]) {
            return 1;
          }
          return 0;
        });
      }
      for (u = 0, len12 = tileList.length; u < len12; u++) {
        tile = tileList[u];
        pageDef.tiles.push(tile);
      }
    }

    generateTileInfo(tileGenInfo, tile) {
      var key, newTile, val;
      // Tiles can be selected either specifically or using data
      // from the tablet configuration - such as favourites
      newTile = {};
      for (key in tile) {
        val = tile[key];
        newTile[key] = val;
      }
      newTile.tileType = tileGenInfo.tileType;
      newTile.pageMode = "pageMode" in tileGenInfo ? tileGenInfo.pageMode : "";
      newTile.tileMode = "tileMode" in tileGenInfo ? tileGenInfo.tileMode : "";
      newTile.tileName = tile[tileGenInfo.tileNameFrom];
      newTile.colType = tileGenInfo.colType != null ? tileGenInfo.colType : "";
      newTile.url = "urlFrom" in tileGenInfo ? tile[tileGenInfo.urlFrom] : ("url" in tileGenInfo ? newTile.url = tileGenInfo.url : void 0);
      if (tileGenInfo.pageGenRule != null) {
        newTile.pageGenRule = tileGenInfo.pageGenRule;
      }
      if (tileGenInfo.rowSpan != null) {
        newTile.rowSpan = tileGenInfo.rowSpan;
      }
      if (tileGenInfo.colSpan != null) {
        newTile.colSpan = tileGenInfo.colSpan;
      }
      newTile.tileText = tile[tileGenInfo.tileTextFrom];
      if ("iconName" in tileGenInfo) {
        newTile.iconName = tileGenInfo.iconName;
      }
      return newTile;
    }

    generateNewPage(context) {
      var col, i, j, k, len, len1, len2, pageGen, ref, ref1, ref2, tabConfig, tile, tileGen;
      tabConfig = this.app.tabletConfigManager.getConfigData();
      if ((context.pageGenRule != null) && context.pageGenRule !== "") {
        if (context.pageGenRule in tabConfig.common.pageGen) {
          pageGen = tabConfig.common.pageGen[context.pageGenRule];
          this.generatedPage = {
            "pageName": "pageNameFrom" in pageGen ? context[pageGen.pageNameFrom] : pageGen.pageName,
            "pageTitle": "pageTitleFrom" in pageGen ? context[pageGen.pageTitleFrom] : pageGen.pageTitle,
            "columns": pageGen.columns,
            "tiles": (function() {
              var i, len, ref, results;
              ref = pageGen.tilesFixed;
              results = [];
              for (i = 0, len = ref.length; i < len; i++) {
                tile = ref[i];
                results.push(tile);
              }
              return results;
            })(),
            "tileGen": (function() {
              var i, len, ref, results;
              ref = pageGen.tileGen;
              results = [];
              for (i = 0, len = ref.length; i < len; i++) {
                tileGen = ref[i];
                results.push(tileGen);
              }
              return results;
            })()
          };
          if ("tileModeFrom" in pageGen) {
            ref = this.generatedPage.tileGen;
            for (i = 0, len = ref.length; i < len; i++) {
              tileGen = ref[i];
              tileGen.tileMode = context[pageGen.tileModeFrom];
            }
          }
          ref1 = this.generatedPage.columns.landscape;
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            col = ref1[j];
            if (col.titleGen != null) {
              col.title = this.generatedPage[col.titleGen];
            }
          }
          ref2 = this.generatedPage.columns.portrait;
          for (k = 0, len2 = ref2.length; k < len2; k++) {
            col = ref2[k];
            if (col.titleGen != null) {
              col.title = this.generatedPage[col.titleGen];
            }
          }
          this.generatePageContents(this.generatedPage, tabConfig);
          return this.generatedPage.pageName;
        }
      }
      return "";
    }

    display() {
      this.curTabPage = new App.TabPage(this.app, this.parentTag, this.curPageDef, this.buttonCallback);
      return this.curTabPage.updateDom();
    }

    buttonCallback(context) {
      var newPageName;
      console.log("buttonCallback user button pressed " + context.url);
      // Check for navigation button
      if ((context.forceReloadPages != null) && context.forceReloadPages) {
        this.app.requestConfigData();
      }
      if ("tileMode" in context && context.tileMode === "SelFavs") {
        this.addFavouriteButton(context);
        this.setCurrentPage(this.defaultPageName, false);
        this.display();
      } else if (indexOf.call(context.url, "/") >= 0) {
        this.automationManager.executeCommand(context.url);
      } else if (indexOf.call(context.url, "~") >= 0) {
        if (this.curTabPage != null) {
          this.curTabPage.handlePageNav(context.url);
        }
      } else if (this.setCurrentPage(context.url, false)) {
        this.display();
      } else if (context.url === "DelFav") {
        this.deleteFavouriteButton(context);
        this.setCurrentPage(this.defaultPageName, false);
        this.display();
      } else if (context.url === "AppUpdate") {
        this.app.appUpdate();
      } else if (context.url === "ExitYes") {
        navigator.app.exitApp();
      } else {
        console.log("WallTabletDebug Attempting page generation " + context.url);
        newPageName = this.generateNewPage(context);
        this.setCurrentPage(newPageName, false);
        this.display();
      }
    }

    addFavouriteButton(context) {
      this.app.tabletConfigManager.addFavouriteButton(context);
      return this.rebuild(false);
    }

    deleteFavouriteButton(context) {
      this.app.tabletConfigManager.deleteFavouriteButton(context);
      return this.rebuild(false);
    }

  };

}).call(this);


//# sourceMappingURL=app-pages.js.map
//# sourceURL=coffeescript
(function() {
  App.TileColours = class TileColours {
    constructor() {
      this.tileColours = [
        "#e7821c", // darkorange
        "#8bc73b", // yellowgreen
        "#a20025", // crimson
        "#1b81e2", // cyan
        "#d80073", // magenta
        "#00b5ac", // lightseagreen
        "#741b47", // deep purple
        "#137409", // green
        "#76608a", // mauve
        // "#6d8764"           # olive
        "#aa00ff", // violet
        "#0f38d3", // mediumblue
        // "#bf9000"           # mustard
        // "#008a00"           # emerald
        // "#671345"           # purple
        "#a08306", // amber
        "#825a2c", // brown
        // "#0050ef"           # cobalt
        // "#a4c400"           # lime
        "#6a00ff", // indigo
        // "#00aba9"           # teal
        "#647687", // steel
        "#9900ff", // purple
        // "#2566c2"           # myblue
        // "#aa6ddf"			# mediumpurple
        "#aca42a" // yellow
      ];
      this.curTileColour = 0;
      return;
    }

    getNextColour() {
      var colour;
      colour = this.tileColours[this.curTileColour];
      this.curTileColour += 1;
      if (this.curTileColour >= this.tileColours.length) {
        this.curTileColour = 0;
      }
      return colour;
    }

  };

}).call(this);


//# sourceMappingURL=tile-colours.js.map
//# sourceURL=coffeescript
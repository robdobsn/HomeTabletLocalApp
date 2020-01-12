(function() {
  App.IframeTile = class IframeTile extends App.Tile {
    constructor(tileDef) {
      super(tileDef);
      this.iframeSource = tileDef.contentUrl;
      return;
    }

    addToDoc(elemToAddTo) {
      super.addToDoc();
      this.contents.append(`<div class="sqIframeTile"\n	style="height:100%;margin:0px;padding:0px;overflow:hidden">\n	<iframe src=${this.iframeSource}\n	   frameborder="0" \n	   style="overflow:hidden"\n	   height="100%" \n	   width="100%">\n	</iframe></div>`);
    }

  };

}).call(this);


//# sourceMappingURL=iframe-tile.js.map
//# sourceURL=coffeescript
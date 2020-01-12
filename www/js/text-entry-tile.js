(function() {
  App.TextEntryTile = class TextEntryTile extends App.Tile {
    constructor(tileDef) {
      super(tileDef);
      this.fontPixels = 30;
      this.leftMarginX = 10;
      this.stateVar = App.LocalStorage.get(tileDef.varName);
      return;
    }

    addToDoc(elemToAddTo) {
      var inputSel;
      super.addToDoc(elemToAddTo);
      this.contents.append(`<span class="sqTextEntryLabel" style="position:relative"></span>\n<span><input class="sqTextEntryInput" style="position:relative; \n	font-size: ${this.fontPixels}px; type="text""></input></span>`);
      inputSel = '#' + this.tileId + " .sqTextEntryInput";
      $(inputSel).bind('input', () => {
        return App.LocalStorage.set(this.tileDef.varName, $(inputSel).val());
      });
    }

    reposition(posX, posY, sizeX, sizeY) {
      var inputSel, labelSel, lblWidth, txtHeight;
      this.posX = posX;
      this.posY = posY;
      this.sizeX = sizeX;
      this.sizeY = sizeY;
      super.reposition(this.posX, this.posY, this.sizeX, this.sizeY);
      labelSel = '#' + this.tileId + " .sqTextEntryLabel";
      inputSel = '#' + this.tileId + " .sqTextEntryInput";
      $(labelSel).text(this.tileDef.label);
      $(inputSel).val(this.stateVar);
      $(labelSel).css({
        fontSize: this.fontPixels + "px"
      });
      $(inputSel).css({
        fontSize: this.fontPixels + "px"
      });
      txtHeight = $(inputSel).height();
      this.setPositionCss(labelSel, this.leftMarginX, (this.sizeY - txtHeight) / 2);
      lblWidth = $(labelSel).width();
      this.setPositionCss(inputSel, null, (this.sizeY - txtHeight) / 2, this.sizeX - lblWidth - 4 * this.leftMarginX);
    }

  };

}).call(this);


//# sourceMappingURL=text-entry-tile.js.map
//# sourceURL=coffeescript
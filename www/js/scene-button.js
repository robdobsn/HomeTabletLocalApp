(function() {
  App.SceneButton = class SceneButton extends App.Tile {
    constructor(tileDef) {
      super(tileDef);
      this.buttonMarginX = 10;
      this.iconSize = [0, 0];
      this.fontPixels = 40;
      this.iconCellWidth = 80;
      return;
    }

    addToDoc(elemToAddTo) {
      var iconName;
      super.addToDoc(elemToAddTo);
      this.contents.append(`<div class="sqSceneButtonIcon" style="position:absolute"></div>\n<div class="sqSceneButtonText" style="position:absolute; font-size: ${this.fontPixels}px;"></div>`);
      iconName = this.tileDef.iconName;
      if (iconName === null) {
        iconName = "";
      }
      this.setIcon(iconName);
      this.setText(this.tileDef.tileText);
    }

    reposition(posX, posY, sizeX, sizeY) {
      var fontScaling, iconHeight, iconSel, iconWidth, iconX, textLeftX, textSel, txtCellWidth, txtHeight, txtWidth;
      this.posX = posX;
      this.posY = posY;
      this.sizeX = sizeX;
      this.sizeY = sizeY;
      super.reposition(this.posX, this.posY, this.sizeX, this.sizeY);
      iconSel = '#' + this.tileId + " .sqSceneButtonIcon";
      textSel = '#' + this.tileId + " .sqSceneButtonText";
      // Handle position with icon
      if (this.iconSize[0] !== 0) {
        iconHeight = this.sizeY / 2;
        iconWidth = iconHeight * this.iconSize[0] / this.iconSize[1];
        if (this.tileDef.iconX === "centre") {
          iconX = (this.sizeX - iconWidth) / 2;
          this.setPositionCss(iconSel, iconX, (this.sizeY - iconHeight) / 2, iconWidth, iconHeight);
        } else {
          iconX = (this.iconCellWidth - iconWidth) / 2;
          this.setPositionCss(iconSel, iconX, (this.sizeY - iconHeight) / 2, iconWidth, iconHeight);
          txtHeight = $(textSel).height();
          textLeftX = this.iconCellWidth;
          this.setPositionCss(textSel, textLeftX, (this.sizeY - txtHeight) / 2);
          txtWidth = $(textSel).width();
          txtCellWidth = this.sizeX - textLeftX - this.buttonMarginX;
          if (txtWidth > txtCellWidth) {
            fontScaling = txtCellWidth / txtWidth;
            $(textSel).css({
              fontSize: (fontScaling * this.fontPixels) + "px"
            });
          }
          txtHeight = $(textSel).height();
          this.setPositionCss(textSel, textLeftX, (this.sizeY - txtHeight) / 2);
        }
      } else {
        // No icon so centre text
        txtHeight = $(textSel).height();
        $(textSel).css({
          textAlign: "center"
        });
        this.setPositionCss(textSel, 0, (this.sizeY - txtHeight) / 2);
        txtWidth = $(textSel).width();
        txtCellWidth = this.sizeX - this.buttonMarginX * 2;
        if (txtWidth > txtCellWidth) {
          fontScaling = txtCellWidth / txtWidth;
          $(textSel).css({
            fontSize: (fontScaling * this.fontPixels) + "px"
          });
        }
        txtWidth = $(textSel).width();
        txtHeight = $(textSel).height();
        this.setPositionCss(textSel, (this.sizeX - txtWidth) / 2, (this.sizeY - txtHeight) / 2);
      }
    }

    setIcon(iconName) {
      var iconUrl, testImage;
      if (iconName === "") {
        return;
      }
      iconUrl = 'img/' + iconName + '.png';
      $('#' + this.tileId + " .sqSceneButtonIcon").html(`<img src=${iconUrl} style='height:100%'></img>`);
      // Create new offscreen image get size from
      testImage = new Image();
      testImage.src = iconUrl;
      this.iconSize = [testImage.width, testImage.height];
    }

    setText(textStr) {
      this.textStr = textStr;
      $('#' + this.tileId + " .sqSceneButtonText").html(this.textStr);
    }

  };

}).call(this);


//# sourceMappingURL=scene-button.js.map
//# sourceURL=coffeescript
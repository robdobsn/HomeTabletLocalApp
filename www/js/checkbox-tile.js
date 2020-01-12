(function() {
  App.CheckBoxTile = class CheckBoxTile extends App.SceneButton {
    constructor(tileDef) {
      super(tileDef);
      this.stateVar = App.LocalStorage.get(tileDef.varName);
      return;
    }

    handleAction(action) {
      if (action === "toggle") {
        this.stateVar = !this.stateVar;
        App.LocalStorage.set(this.tileDef.varName, this.stateVar);
      }
      this.setIcon();
    }

    setIcon() {
      if (this.stateVar === true) {
        super.setIcon(this.tileDef.iconName);
      } else {
        super.setIcon(this.tileDef.iconNameOff);
      }
    }

  };

}).call(this);


//# sourceMappingURL=checkbox-tile.js.map
//# sourceURL=coffeescript
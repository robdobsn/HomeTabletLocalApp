(function() {
  App.MediaPlayHelper = class MediaPlayHelper {
    constructor(soundsDict) {
      this.soundsDict = soundsDict;
      this.soundsLoaded = {};
      return;
    }

    getPhoneGapPath() {
      var path;
      path = window.location.pathname;
      path = path.substr(path, path.length - 10);
      if (path.substr(-1) !== '/') {
        path = path + '/';
      }
      return 'file://' + path;
    }

    play(soundName) {
      var bTryAudio, e, snd;
      if (soundName in this.soundsDict) {
        bTryAudio = false;
        if (window.plugins && window.plugins.LowLatencyAudio) {
          try {
            if (!(soundName in this.soundsLoaded)) {
              console.log("WallTabletDebug Preloading audio " + soundName);
              window.plugins.LowLatencyAudio.preloadAudio(soundName, this.soundsDict[soundName], 1, 1, this.onSuccess, this.onErrorPreload);
              this.soundsLoaded[soundName] = true;
            }
            console.log("WallTabletDebug Playing audio");
            window.plugins.LowLatencyAudio.play(soundName, this.onSuccess, this.onErrorPlay);
          } catch (error1) {
            e = error1;
            bTryAudio = true;
          }
        } else {
          bTryAudio = true;
        }
        if (bTryAudio) {
          try {
            snd = new Audio(this.soundsDict[soundName]);
            snd.play();
          } catch (error1) {
            e = error1;
            console.log("WallTabletDebug LowLatencyAudio and Audio both failed");
          }
        }
      }
    }

    onSuccess(result) {
      console.log("WallTabletDebug LowLatencyAudio success result = " + result);
    }

    onErrorPreload(error) {
      console.log("WallTabletDebug LowLatencyAudio preload error = " + error);
    }

    onErrorPlay(error) {
      console.log("WallTabletDebug LowLatencyAudio play error = " + error);
    }

  };

}).call(this);


//# sourceMappingURL=media-play-help.js.map
//# sourceURL=coffeescript
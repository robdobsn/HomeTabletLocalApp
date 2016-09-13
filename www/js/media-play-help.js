// Generated by CoffeeScript 1.10.0
(function() {
  App.MediaPlayHelper = (function() {
    function MediaPlayHelper(soundsDict) {
      this.soundsDict = soundsDict;
      this.soundsLoaded = {};
      return;
    }

    MediaPlayHelper.prototype.getPhoneGapPath = function() {
      var path;
      path = window.location.pathname;
      path = path.substr(path, path.length - 10);
      if (path.substr(-1) !== '/') {
        path = path + '/';
      }
      return 'file://' + path;
    };

    MediaPlayHelper.prototype.play = function(soundName) {
      var bTryAudio, e, error1, error2, snd;
      if (soundName in this.soundsDict) {
        bTryAudio = false;
        if (window.plugins && window.plugins.LowLatencyAudio) {
          try {
            if (!(soundName in this.soundsLoaded)) {
              console.log("Preloading audio " + soundName);
              window.plugins.LowLatencyAudio.preloadAudio(soundName, this.soundsDict[soundName], 1, 1, this.onSuccess, this.onErrorPreload);
              this.soundsLoaded[soundName] = true;
            }
            console.log("Playing audio");
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
          } catch (error2) {
            e = error2;
            console.log("LowLatencyAudio and Audio both failed");
          }
        }
      }
    };

    MediaPlayHelper.prototype.onSuccess = function(result) {
      console.log("LowLatencyAudio success result = " + result);
    };

    MediaPlayHelper.prototype.onErrorPreload = function(error) {
      console.log("LowLatencyAudio preload error = " + error);
    };

    MediaPlayHelper.prototype.onErrorPlay = function(error) {
      console.log("LowLatencyAudio play error = " + error);
    };

    return MediaPlayHelper;

  })();

}).call(this);

//# sourceMappingURL=media-play-help.js.map

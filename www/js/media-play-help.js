// Generated by CoffeeScript 1.7.1
var MediaPlayHelper;

MediaPlayHelper = (function() {
  function MediaPlayHelper(soundsDict) {
    this.soundsDict = soundsDict;
    this.soundsLoaded = {};
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
    var bTryAudio, e, snd;
    if (soundName in this.soundsDict) {
      bTryAudio = false;
      if (window.plugins && window.plugins.LowLatencyAudio) {
        try {
          if (!(soundName in this.soundsLoaded)) {
            window.plugins.LowLatencyAudio.preloadAudio(soundName, this.soundsDict[soundName], 1, this.onSuccess, this.onError);
            this.soundsLoaded[soundName] = true;
          }
          window.plugins.LowLatencyAudio.play(soundName, this.onSuccess, this.onError);
        } catch (_error) {
          e = _error;
          bTryAudio = true;
        }
      } else {
        bTryAudio = true;
      }
      if (bTryAudio) {
        try {
          snd = new Audio(this.soundsDict[soundName]);
          return snd.play();
        } catch (_error) {
          e = _error;
          return console.log("LowLatencyAudio and Audio both failed");
        }
      }
    }
  };

  MediaPlayHelper.prototype.onSuccess = function(result) {
    return console.log("LLAUDIO result = " + result);
  };

  MediaPlayHelper.prototype.onError = function(error) {
    return console.log("LLAUDIO error = " + error);
  };

  return MediaPlayHelper;

})();

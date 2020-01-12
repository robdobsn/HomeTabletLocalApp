(function() {
  App.UserIdleCatcher = class UserIdleCatcher {
    constructor(interval, cbFunction) {
      this.interval = interval;
      this.cbFunction = cbFunction;
      this.idleTime = 0;
      $("html").mousemove(() => {
        return this.resetIdleTimer();
      });
      $("html").keypress(() => {
        return this.resetIdleTimer();
      });
      $("html").scroll(() => {
        return this.resetIdleTimer();
      });
      window.addEventListener('touchstart', () => {
        return this.resetIdleTimer();
      });
      setInterval(() => {
        this.idleTime += 1;
        if (this.idleTime >= this.interval) {
          this.idleTime = 0;
          return this.cbFunction();
        }
      }, 1000);
    }

    resetIdleTimer() {
      return this.idleTime = 0;
    }

  };

}).call(this);


//# sourceMappingURL=user-idle-catcher.js.map
//# sourceURL=coffeescript
class TimeSync {
  constructor() {
    this.ts = undefined;
  }

  init() {
    if (!this.ts) {
      this.ts = timesync.create({
        server: '/timesync',
        interval: 60000,
        repeat: 1
      });
    }
  }

  now() {
    this.init();
    return parseInt(this.ts.now().toFixed());
  }

  timestamp() {
    this.init();
    return (new Date(this.ts.now())).toLocaleTimeString();
  }

  humanTime(millisec) {
    var seconds = (millisec / 1000).toFixed(0);
    var minutes = Math.floor(seconds / 60);
    var hours = "";
    if (minutes > 59) {
        hours = Math.floor(minutes / 60);
        hours = (hours >= 10) ? hours : "0" + hours;
        minutes = minutes - (hours * 60);
        minutes = (minutes >= 10) ? minutes : "0" + minutes;
    }

    seconds = Math.floor(seconds % 60);
    seconds = (seconds >= 10) ? seconds : "0" + seconds;
    if (hours != "") {
        return hours + ":" + minutes + ":" + seconds;
    }
    return minutes + ":" + seconds;
  }
}

timeSync = new TimeSync();

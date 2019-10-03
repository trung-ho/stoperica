class RaceTime extends React.Component {
  constructor() {
    super();

    this.onChange = this.onChange.bind(this);
    this.columnClass = this.columnClass.bind(this);
    this.state = {
      raceTimes: []
    }
  }

  onChange() {
    const storeRaceTimes = DraftResultStore.getStartedRaceData();
    if(storeRaceTimes.length > 0) {
      setInterval(() => {
        let raceTimes = storeRaceTimes.map((time) => {
          return {...time, raceTime: timeSync.humanTime(timeSync.now() - new Date(time.started_at))};
        });
        
        this.setState({raceTimes: raceTimes});
      }, 1000);
    }
  }

  componentWillMount() {
    DraftResultStore.on('draftResultStore.startRace', this.onChange);
  }

  componentWillUnmount() {
    DraftResultStore.off('draftResultStore.startRace', this.onChange);
  }

  columnClass(length) {
    return `mdl-cell mdl-cell--${Math.floor(12/this.state.raceTimes.length)}-col`;
  }

  render() {
    return(
      <span id="raceTime">
        { this.state.raceTimes.length > 0  ?
          (
            <div className="mdl-grid">
              {this.state.raceTimes.map((race) => {
                return (
                  <div key={race.id} className={this.columnClass()}>
                    <h2>
                      {race.raceTime}
                    </h2>
                    <div className="category-name">
                      ({race.name})
                    </div>
                  </div>
                )
              })}
            </div>
          )
          :
          this.state.raceTimes.length > 0 ?
            (
              <div>
                <h1>
                  {this.state.raceTimes[0].raceTime}
                </h1>
                <div className="race-name">
                  ({this.state.raceTimes[0].name})
                </div>
              </div>
            )
            : null
        }
      </span>
    )
  }
}

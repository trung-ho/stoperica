class RaceResultForm extends React.Component {
    constructor() {
        super();

        this.saveResult = this.saveResult.bind(this);
        this.updateStartNumber = this.updateStartNumber.bind(this);
        this.updateHours = this.updateHours.bind(this);
        this.updateMinutes = this.updateMinutes.bind(this);
        this.updateSeconds = this.updateSeconds.bind(this);
        this.updateMillis = this.updateMillis.bind(this);
        this.updateReaderId = this.updateReaderId.bind(this);

        this.state = {
          racerNumber: undefined,
          hours: 0,
          minutes: 0,
          seconds: 0,
          millis: 0,
          readerId: 0
        }
    }

    getOptions(count, key) {
      let options = [];
      for (var i = 0; i < count; i++) {
        options.push(<option key={key + i} value={i}>{i} {key}</option>);
      }
      return options;
    }

    saveResult() {
      const {racerNumber, hours, minutes, seconds, millis, readerId} = this.state;
      const raceId = DraftResultStore.getRaceId();
      let ajax = new Ajax(
        `/start_numbers/start_time?race_id=${raceId}&start_number=${racerNumber}`,
        data => {
          const startTime = data.start_time;
          let time = new Date(data.start_time).getTime();
          time += hours*3600000;
          time += minutes*60000;
          time += seconds*1000;
          time += millis*1;

          if(racerNumber && time) {
            RaceResultActions.newRaceResult(racerNumber, time, 3, readerId);
          }
          else {
            alert('Ispuni sva polja!');
          }
        }
      );

      ajax.get();
    }

    updateStartNumber(event) {
      this.setState({racerNumber: event.target.value});
    }

    updateHours(event) {
      this.setState({hours: event.target.value});
    }

    updateMinutes(event) {
      this.setState({minutes: event.target.value});
    }

    updateSeconds(event) {
      this.setState({seconds: event.target.value});
    }

    updateMillis(event) {
      this.setState({millis: event.target.value});
    }

    updateReaderId(event) {
      this.setState({readerId: event.target.value});
    }

    render() {
        return (
          <div className="race-result-form">
              <h4>Dodaj rezultat</h4>
              <p><input type="number" min="1" placeholder="Startni broj" onKeyUp={this.updateStartNumber}/></p>
              <label htmlFor="">Vrijeme</label>
              <p>
                <select
                  name="raceResultHours"
                  id="raceResultHours"
                  className="tiny"
                  onChange={ this.updateHours }
                >
                  {this.getOptions(6, 'h')}
                </select>
                <select
                  name="raceResultMinutes"
                  id="raceResultMinutes"
                  className="tiny"
                  onChange={ this.updateMinutes }
                >
                  {this.getOptions(60, 'min')}
                </select>
                <select
                  name="raceResultSeconds"
                  id="raceResultSeconds"
                  className="tiny"
                  onChange={ this.updateSeconds }
                >
                  {this.getOptions(60, 'sec')}
                </select>
                <select
                  name="raceResultMillis"
                  id="raceResultMillis"
                  className="tiny"
                  onChange={ this.updateMillis }
                >
                  {this.getOptions(1000, 'ms')}
                </select>
              </p>
              <label>Reader ID</label>
              <p><input type="text" placeholder="Reader ID" onKeyUp={this.updateReaderId}/></p>
              <div>
                <button
                  className={`mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect`}
                  onClick={this.saveResult}
                >
                  Spremi
                </button>
              </div>
          </div>
        );
    }
}

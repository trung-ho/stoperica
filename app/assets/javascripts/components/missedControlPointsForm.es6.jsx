const blankState = () => ({
  missed_control_points: 0,
  start_number: '',
  race_id: DraftResultStore.getRaceId()
});

class MissedControlPointsForm extends React.Component {
  constructor() {
    super();

    this.updateNumber = this.updateNumber.bind(this);
    this.updateMissed = this.updateMissed.bind(this);
    this.save = this.save.bind(this);

    this.state = blankState();
  }

  updateNumber(event) {
    this.setState({ start_number: event.target.value })
  }

  updateMissed(event) {
    this.setState({ missed_control_points: event.target.value })
  }

  save() {
    const data = {...this.state, race_id: DraftResultStore.getRaceId() };
    const ajax = new Ajax(
      '/race_results/update_missed',
      data => {
        alert(`Spremljen broj ${this.state.start_number}.`);
        this.setState = blankState();
      },
      () => alert('Greska! Nije spremljeno.')
    );
    ajax.post(data);
  }

  render() {
    return (
      <div>
        <h4>Zaostatak Kontrolnih tocki</h4>
        <div className="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
          <input className="mdl-textfield__input" type="text" id="number" onKeyUp={this.updateNumber}/>
          <label className="mdl-textfield__label" htmlFor="number">Startni broj</label>
        </div>
        <div className="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
          <input className="mdl-textfield__input" type="text" id="missed" onKeyUp={this.updateMissed}/>
          <label className="mdl-textfield__label" htmlFor="missed">Zaostatak</label>
        </div>
        <button
          onClick={ this.save }
          className="mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect"
          style={{display: 'block'}}
        >
          Spremi
        </button>
      </div>
    );
  }
}

class ClimbingTiming extends React.Component {
  constructor() {
    super();

    this.saveResult = this.saveResult.bind(this);
  }

  saveResult(event) {
    event.preventDefault();
    const { form } = this.refs;
    const data = new FormData(form);
    const json = {
      race_id: DraftResultStore.getRaceId(),
      start_number: data.get('start_number'),
      level: data.get('level'),
      points: data.get('points'),
      time: data.get('time')
    }
    this.uploadResult(json);
  }

  uploadResult(data) {
    const ajax = new Ajax(
      '/race_results/from_climbing',
      data => console.log(data),
      (error, status) => console.log(error, status)
    );
    ajax.post(data);
  }

  render () {
    return (
      <div>
        <div className="mdl-grid">
          <div className="mdl-cell mdl-cell--2-col">
            Startni broj
          </div>
          <div className="mdl-cell mdl-cell--2-col">
            Odaberi razinu
          </div>
          <div className="mdl-cell mdl-cell--2-col">
            Bodovanje
          </div>
          <div className="mdl-cell mdl-cell--2-col">
            Vrijeme
          </div>
          <div className="mdl-cell mdl-cell--2-col">
            Spremi
          </div>
        </div>
        <form ref="form" className="mdl-grid">
          <input
            name="start_number"
            type="text"
            className="mdl-cell mdl-cell--2-col"/>
          <select name="level" className="mdl-cell mdl-cell--2-col">
            <option value="q1">Q1</option>
            <option value="q2">Q2</option>
            <option value="finale">Finale</option>
          </select>
          <input name="points" type="text" className="mdl-cell mdl-cell--2-col"/>
          <input name="time" type="text" className="mdl-cell mdl-cell--2-col"/>
          <button onClick={ this.saveResult } className="mdl-cell mdl-cell--2-col mdl-button mdl-js-button mdl-button--raised mdl-button--accent mdl-js-ripple-effect">Spremi</button>
        </form>
        <hr/>
        <ClimbingResults/>
      </div>
    );
  }
}

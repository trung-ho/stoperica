class DraftResult extends React.Component {
  constructor() {
    super();

    this.uploadResult = this.uploadResult.bind(this);

    this.state = {
      status: 'uploading',
      racerName: undefined,
      failed: false
    }
  }

  uploadResult() {
    let data = {
      start_number: this.props.result.racerNumber,
      race_id: DraftResultStore.getRaceId(),
      time: this.props.result.time,
      status: this.props.result.status,
      reader_id: this.props.result.readerId
    };

    let ajax = new Ajax(
      '/race_results/from_timing',
      (data) => {
        this.setState({
          status: 'spremljeno',
          failed: false,
          racerName: `${data.racer.first_name} ${data.racer.last_name}`
        })
      },
      (error, status) => {
        console.log(error, status);
        this.setState({status: 'nije uspjelo', failed: true})
      }
    );

    this.setState({status: 'uploading', failed: false})

    ajax.post(data);
  }

  componentDidMount() {
    this.uploadResult();
  }

  render() {
    const {result} = this.props;
    const raceStartTime = DraftResultStore.getRaceStartDate();
    const timeDiff = result.time - raceStartTime;
    return (
      <tr>
        <td>{result.racerNumber}</td>
        <td>{this.state.racerName ? this.state.racerName : ''}</td>
        <td>
          {timeSync.humanTime(timeDiff)}
        </td>
        <td>
          {this.state.status}
        </td>
        <td>
          <button
            className={`${this.state.failed ? '' : 'hidden'} mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect`}
            onClick={this.uploadResult}
          >
            Upload
          </button>
          {
           !this.state.failed ?
           null
           :
            <button
              className="mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect"
              onClick={() => {RaceResultActions.removeRaceResult(this.props.result.racerNumber)}}
            >
              Makni s liste
            </button>
          }
        </td>
      </tr>
    );
  }
}

class ClimbingResults extends React.Component {
  constructor() {
    super();

    this.state = {
      race: {},
      interval: null
    };

    this.loadResults = this.loadResults.bind(this);
  }

  componentDidMount() {
    this.loadResults();
    // this.setState({ interval: setInterval(this.loadResults , 10000) });
  }

  componentWillUnmount() {
    // clearInterval(this.state.interval);
    // this.setState({ interval: null });
  }

  loadResults() {
    if (!DraftResultStore.getRaceId()) return;
    const ajax = new Ajax(
      `/races/${ DraftResultStore.getRaceId() }`,
      data => this.setState({ race: data }),
      (error, status) => console.log(error, status)
    );
    ajax.get();
  }

  render () {
    const { race_results = [] } = this.state.race;
    return (
      <table className="wide_table mdl-data-table mdl-js-data-table mdl-shadow--2dp">
        <thead>
          <tr>
            <th>Start Number</th>
            <th>Climber</th>
            <th>Q1</th>
            <th>RQ1</th>
            <th>Q2</th>
            <th>RQ2</th>
            <th>RQ</th>
            <th>QRank</th>
            <th>RF</th>
            <th>PLF</th>
            <th>FTime</th>
          </tr>
        </thead>
        <tbody>
        {
          race_results.map(result => {
            return (
              <tr key={result.id}>
                <td>{result.start_number && result.start_number.value}</td>
                <td>{result.racer.first_name} {result.racer.last_name}</td>
                <td>{result.climbs.q1 && result.climbs.q1.points}</td>
                <td>{result.climbs.q1 && result.climbs.q1.position}</td>
                <td>{result.climbs.q2 && result.climbs.q2.points}</td>
                <td>{result.climbs.q2 && result.climbs.q2.position}</td>
                <td>{result.climbs.q && result.climbs.q.points}</td>
                <td>{result.climbs.q && result.climbs.q.position}</td>
                <td>{result.climbs.finale && result.climbs.finale.points}</td>
                <td>{result.climbs.finale && result.climbs.finale.position}</td>
                <td>{result.climbs.finale && result.climbs.finale.time}</td>
              </tr>
            );
          })
        }
        </tbody>
      </table>
    );
  }
}

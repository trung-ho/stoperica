class LiveResults extends React.Component {
  constructor() {
    super();

    this.state = {
      raceId: undefined,
      message: undefined
    }
  }

  componentWillMount() {
    this.ajax = new Ajax(
      '/races/get_live',
      (data) => {
        if(data != null) {
          if (data[0] && data[0].race_id) {
            this.setState({raceId: data[0].race_id});
          } else if (data[0]) {
            this.setState({raceId: data[0].id});
          }
          else {
            this.setState({message: 'Nema aktivne utrke.'});  
          }

          RaceResultActions.startRace(data);
        }
        else {
          this.setState({message: 'Nema aktivne utrke.'});
        }
      },
      (error, status) => {
        this.setState({message: `${error} ${status}`});
      }
    );

    this.ajax.get();
  }

  render() {
    return(
      <span id="liveResults">
        {
          this.state.message ?
          <h1>{this.state.message}</h1>
          : null
        }
        <RaceTime />
        <hr/>
        {
          this.state.raceId ?
          <RaceResults raceId={this.state.raceId} />
          : null
        }
      </span>
    )
  }
}

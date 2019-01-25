class RaceResults extends React.Component {
  constructor() {
    super();

    this._handleSwitchView = this._handleSwitchView.bind(this);
    this._handleSwitchSize = this._handleSwitchSize.bind(this);
    this._handleSwitchOrder = this._handleSwitchOrder.bind(this);
    this._renderSequential = this._renderSequential.bind(this);
    this._renderByCategory = this._renderByCategory.bind(this);

    this.state = {
      race: { race_results: [] },
      categoryView: false,
      largeView: false,
      newestFirst: false,
      categories: []
    }
  }

  _handleSwitchView(event) {
    this.setState({categoryView: event.target.checked})
  }

  _handleSwitchSize(event) {
    this.setState({largeView: event.target.checked})
  }

  _handleSwitchOrder(event) {
    this.setState({newestFirst: event.target.checked})
  }

  _renderSequential() {
    const newestFirst = this.state.newestFirst;
    return this.state.race.race_results.filter((a)=>{
        return a.live_time.time != '- -' && a.status == 3
      }).sort((a, b)=>{
        if(newestFirst){
          if(a.live_time.time < b.live_time.time)
            return 1;
          else if(a.live_time.time === b.live_time.time)
            return 0
          else
            return -1;
        }
        else {
          if(a.live_time.time > b.live_time.time)
            return 1;
          else if(a.live_time.time === b.live_time.time)
            return 0
          else
            return -1;
        }
      }).map((raceResult)=>{
        return (<tr key={`race-result-${raceResult.id}`}>
          <td>{raceResult.start_number && raceResult.start_number.value}</td>
          <td>{raceResult.category.name.toUpperCase()}</td>
          <td>{`${raceResult.racer.first_name} ${raceResult.racer.last_name}`}</td>
          <td>{raceResult.racer && raceResult.racer.club && raceResult.racer.club.name}</td>
          <td>{raceResult.live_time.time} {raceResult.live_time.control_point}</td>
          <td></td>
        </tr>)
      });
  }

  _renderActive() {
    return this.state.race.race_results.filter((a)=>{
        return a.live_time.time === '- -'
      }).map((raceResult)=>{
        return (<tr key={`race-result-${raceResult.id}`}>
          <td>{raceResult.start_number && raceResult.start_number.value}</td>
          <td>{raceResult.category.name.toUpperCase()}</td>
          <td>{`${raceResult.racer.first_name} ${raceResult.racer.last_name}`}</td>
          <td>{raceResult.racer && raceResult.racer.club && raceResult.racer.club.name}</td>
          <td>{this._prettyStatus(raceResult.status)}</td>
        </tr>)
      });
  }

  _renderByCategory() {
    const { newestFirst, categories } = this.state;
    let finishedTimes = this.state.race.race_results.filter((a)=>{
      return a.live_time.time != '- -' && a.status == 3
    });

    return categories.map((category, index) => {
      return [<tr className={`cat-${index}`}><td colSpan="6"><b>{category.toUpperCase()}</b></td></tr>].concat(finishedTimes.filter((a)=>{
          return a.category.name === category;
        })
        .sort((a, b)=>{
          if(newestFirst){
            if(a.live_time.time < b.live_time.time)
              return 1;
            else if(a.live_time.time === b.live_time.time)
              return 0
            else
              return -1;
          }
          else {
            if(a.live_time.time > b.live_time.time)
              return 1;
            else if(a.live_time.time === b.live_time.time)
              return 0
            else
              return -1;
          }
        }).map((raceResult)=>{
          return (<tr key={`race-result-${raceResult.id}`}>
            <td>{raceResult.start_number && raceResult.start_number.value}</td>
            <td>{raceResult.category.name.toUpperCase()}</td>
            <td>{`${raceResult.racer.first_name} ${raceResult.racer.last_name}`}</td>
            <td>{raceResult.racer && raceResult.racer.club && raceResult.racer.club.name}</td>
            <td>{raceResult.live_time.time} {raceResult.live_time.control_point}</td>
            <td></td>
          </tr>)
        }));
    });
  }

  _prettyStatus(status) {
    switch(status) {
      case 1:
        return 'Prijavljen';
      case 2:
        return 'Na stazi';
      case 3:
        return 'Zavrsio';
      case 4:
        return 'DNF';
      case 5:
        return 'DSQ';
      case 6:
        return 'DNS';
      default:
        return 'Prijavljen'
    }
  }

  componentWillMount() {
    this.ajax = new Ajax(
      `/races/${this.props.raceId}?unsorted=true`,
      (data) => {
        data.race_results = data.race_results.filter(it => !!it.start_number_id)
        this.setState({
          race: data,
          categories: data.categories.map(c => c.name)
        })
      },
      (error, status) => {
        alert(error + status);
      }
    );

    this.ajax.get();

    this.interval = setInterval(() => this.ajax.get(), 20000);
  }

  componentWillUnmount() {
    clearInterval(this.interval);
  }

  render () {
    return(
      <div>
        <h2>Trenutni rezultati</h2>

        <label htmlFor="switch1" className="mdl-cell mdl-cell--4-col mdl-cell--12-col-phone mdl-switch mdl-js-switch mdl-js-ripple-effect">
          <input type="checkbox" id="switch1" className="mdl-switch__input" onClick={this._handleSwitchView} />
          <span className="mdl-switch__label">Prikaz po kategorijama</span>
        </label>

        <label htmlFor="switch2" className="mdl-cell mdl-cell--4-col mdl-cell--12-col-phone mdl-switch mdl-js-switch mdl-js-ripple-effect">
          <input type="checkbox" id="switch2" className="mdl-switch__input" onClick={this._handleSwitchSize} />
          <span className="mdl-switch__label">Veliki prikaz</span>
        </label>

        <label htmlFor="switch3" className="mdl-cell mdl-cell--4-col mdl-cell--12-col-phone mdl-switch mdl-js-switch mdl-js-ripple-effect">
          <input type="checkbox" id="switch3" className="mdl-switch__input" onClick={this._handleSwitchOrder} />
          <span className="mdl-switch__label">Najnoviji prvi</span>
        </label>
        <br/>
        <br/>
        <table
          className={`${this.state.largeView ? 'large-view' : ''} mdl-data-table wide_table mdl-js-data-table mdl-data-table--selectable mdl-shadow--2dp`}
        >
          <thead>
            <tr>
              <td>Broj</td>
              <td>Kategorija</td>
              <td>Ime</td>
              <td>Klub</td>
              <td>Vrijeme</td>
              <td></td>
            </tr>
          </thead>
          <tbody>
            {
              this.state.categoryView ?
              this._renderByCategory()
              :
              this._renderSequential()
            }
          </tbody>
        </table>

        <h2>Nisu zavrsili</h2>

        <table
          className={`${this.state.largeView ? 'large-view' : ''} mdl-data-table wide_table mdl-js-data-table mdl-data-table--selectable mdl-shadow--2dp`}
        >
          <thead>
            <tr>
              <td>Broj</td>
              <td>Kategorija</td>
              <td>Ime</td>
              <td>Klub</td>
              <td>Status</td>
            </tr>
          </thead>
          <tbody>
            {
              this._renderActive()
            }
          </tbody>
        </table>
      </div>
    );
  }
}

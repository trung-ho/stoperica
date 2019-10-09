class RaceStart extends React.Component {
  constructor() {
    super();

    this.state = {
      selectedRace: {},
      raceStarted: false,
      categories: [],
      selectedCategories: [],
      timestamp: timeSync.timestamp()
    }
  }

  selectRace(event) {
    let raceId = event.target.value;
    let ajax = new Ajax(
      `/races/${raceId}.json`,
      data => {
        if(data.started_at) {
          RaceResultActions.startRace(new Date(data.started_at));
          this.setState({ raceStarted: true });
        }
        RaceResultActions.setRace(data);
        this.setState({
          selectedRace: data,
          categories: data.categories
        });
      },
      (error, status) => {
        console.log(error, status);
      }
    );

    ajax.get();
  }

  startRace() {
    const { selectedCategories, selectedRace, categories } = this.state;
    let data = {
      started_at: timeSync.now(),
      categories: selectedCategories
    }
    let ajax = new Ajax(
      `/races/${selectedRace.id}`,
      data => {
        const updatedCategories = categories.map(c => {
          if (selectedCategories.indexOf(c.id.toString()) > -1) {
            c['started?'] = true;
          }
          return c;
        });
        this.setState({
          raceStarted: true,
          selectedCategories: [],
          categories: updatedCategories
        });
        RaceResultActions.startRace(new Date(data.started_at));
        RaceResultActions.setRace(selectedRace);
        const startedCategories = categories.map(c => {
          if (selectedCategories.includes(c.id.toString())) return c.name;
        });
        window.alert(`Startali: ${startedCategories.join(', ')}`)
      },
      (error, status) => {
        console.log(error, status);
      }
    );

    ajax.put(data);
  }

  endRace() {
    let data = {
      ended_at: timeSync.now()
    }
    let ajax = new Ajax(
      `/races/${this.state.selectedRace.id}`,
      (data) => {
        window.location = `/races/${this.state.selectedRace.id}`;
      },
      (error, status) => {
        console.log(error, status);
      }
    );
    ajax.put(data);
  }

  handleCategoryChange({ target }, category) {
    const { selectedCategories } = this.state;
    if (target.checked) {
      selectedCategories.push(target.value);
    }
    else {
      const index = selectedCategories.indexOf(target.value);
      selectedCategories.splice(index, 1);
    }
    this.setState({ selectedCategories })
  }

  componentDidMount() {
    setInterval(() => {
      this.setState({ timestamp: timeSync.timestamp() })
    }, 1000)
  }

  render () {
    const { races } = this.props;
    if (this.state.selectedRace.race_type === 'penjanje') {
      return (<ClimbingTiming />);
    }
    return (
      <span>
        <span>
          <select
            name=""
            id=""
            style={{ width: '180px', marginRight: '2em' }}
            onChange={ this.selectRace.bind(this) }
          >
            <option value="0">Odaberi utrku</option>
            {
              races.sort((a, b) => (b.id - a.id)).map((race)=>{
                return <option key={`race-select-${race.id}`} value={race.id}>{race.name}</option>;
              })
            }
          </select>
          {
            this.state.selectedRace.id ?
            <button
              className="mdl-button mdl-js-button mdl-button--raised mdl-button--accent mdl-js-ripple-effect"
              onClick={ this.endRace.bind(this) }
              >
              Finish
            </button>
            :
            null
          }
          {
            this.state.selectedRace.id ?
            (
              <button
                className="mdl-button mdl-js-button mdl-button--raised mdl-button--colored mdl-js-ripple-effect"
                onClick={ this.startRace.bind(this) }
              >
                Start
              </button>
            )
            :
            null
          }
          <ul className="timing-category-list">
            {
              this.state.categories.map(c => {
                return (
                  <li key={c.id} title={ c.started_at }>
                    <input
                      type="checkbox"
                      value={c.id}
                      onChange={ event => this.handleCategoryChange(event, c) }
                    />
                    <label className={ c['started?'] ? 'started' : '' }>
                      {c.name}
                    </label>
                  </li>
                );
              })
            }
          </ul>
          <span style={{ marginLeft: '2rem', fontWeight: 'bold' }}>
            Vrijeme timinga: { this.state.timestamp }
          </span>
        </span>
        <RaceTime />
        {
          this.state.raceStarted ?
          <p> Utrka startala: <b>{(new Date(DraftResultStore.getRaceStartDate())).toLocaleString()}</b></p>
          :
          null
        }
      </span>
    );
  }
}

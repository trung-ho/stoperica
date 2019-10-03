var DraftResultStore = flux.createStore({
    raceResults: [],
    uploadedResults: [],
    tempResults: [],
    raceStartDate: undefined,
    race: {},
    actions: [
      RaceResultActions.newRaceResult,
      RaceResultActions.newTempResult,
      RaceResultActions.removeRaceResult,
      RaceResultActions.removeTempResult,
      RaceResultActions.startRace,
      RaceResultActions.setRace
    ],
    newRaceResult: function(racerNumber, time, status, readerId) {
        this.raceResults.push({ racerNumber, time, status, readerId });
        this.emit('draftResultStore.change');
    },
    newTempResult: function(time) {
        this.tempResults.push({ time });
        this.emit('draftResultStore.newTempResult');
    },
    removeRaceResult: function(racerNumber) {
        this.raceResults.forEach((raceResult, index)=>{
            if(raceResult.racerNumber === racerNumber) {
                this.raceResults.splice(index, 1);
                return;
            }
        });
        this.emit('draftResultStore.change');
    },
    removeTempResult: function(time) {
        this.tempResults.forEach((tempResult, index)=>{
            if(tempResult.time === time) {
                this.tempResults.splice(index, 1);
                return;
            }
        });
        this.emit('draftResultStore.newTempResult');
    },
    startRace: function(startedRaceData) {
        this.startedRaceData = startedRaceData;
        this.emit('draftResultStore.startRace');
    },
    setRace: function(race) {
        this.race = race;
        this.emit('draftResultStore.setRace');
    },
    exports: {
        getRaceId: function () {
            return this.race && this.race.id;
        },
        getRaceType: function () {
            return this.race && this.race.race_type;
        },
        getRaceResults: function () {
            return this.raceResults;
        },
        getTempResults: function () {
            return this.tempResults;
        },
        getUploadedResults: function () {
            return this.raceResults;
        },
        getStartedRaceData: function() {
          return this.startedRaceData;
        }
    }
});

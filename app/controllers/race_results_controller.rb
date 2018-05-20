class RaceResultsController < ApplicationController
  before_action :set_race_result, only: [:show, :edit, :update, :destroy]
  before_action :only_admin, only: [:from_timing, :destroy_from_timing]
  before_action :set_start_number, only: [:from_timing, :destroy_from_timing]

  protect_from_forgery :except => [:from_device]

  # GET /race_results
  # GET /race_results.json
  def index
    @race_results = RaceResult.all
  end

  # GET /race_results/1
  # GET /race_results/1.json
  def show
  end

  # GET /race_results/new
  def new
    @race_result = RaceResult.new
  end

  # GET /race_results/1/edit
  def edit
  end

  # POST /race_results
  # POST /race_results.json
  def create
    @race_result = RaceResult.new(race_result_params)
    RacerMailer.race_details(
      @race_result.racer,
      @race_result.race
    ).deliver_later if @race_result.race.email_body

    respond_to do |format|
      if @race_result.save
        format.html { redirect_to @race_result.race, notice: 'Prijava je zabiljezena.' }
        format.json { render :show, status: :created, location: @race_result }
      else
        format.html { render :new }
        format.json { render json: @race_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /race_results/1
  # PATCH/PUT /race_results/1.json
  def update
    start_number_val = params[:race_result][:start_number]
    if start_number_val
      start_number = StartNumber.find_by(value: start_number_val, race: @race_result.race)
      start_number = StartNumber.find_by(value: start_number_val) if start_number.nil?
      raise 'Start number not found' if start_number.nil?
      @race_result.update!(start_number: start_number)
    end

    respond_to do |format|
      if @race_result.update(race_result_params)
        format.html { redirect_to @race_result.race, notice: 'Uplata uspjesno zaprimljena.' }
        format.json { render :show, status: :ok, location: @race_result }
      else
        format.html { render :edit }
        format.json { render json: @race_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /race_results/1
  # DELETE /race_results/1.json
  def destroy
    race = @race_result.race
    @race_result.destroy
    respond_to do |format|
      format.html { redirect_to race, notice: 'Odjava je bila uspjesna.' }
      format.json { head :no_content }
    end
  end

  # POST /race_results/from_timing
  def from_timing
    race_result = RaceResult.find_by(race_id: params[:race_id], start_number: @start_number)
    race_result.lap_times << params[:time].to_f/1000 if params[:time]
    race_result.status = params[:status]
    race_result.save!
    respond_to do |format|
      format.json { render json: race_result }
    end
  end

  # DELETE /race_results/destroy_from_timing
  def destroy_from_timing
    race_result = RaceResult.find_by(race_id: params[:race_id], start_number: @start_number)
    race_result.lap_times -= ["#{params[:time].to_f/1000}"]
    race_result.save!
    respond_to do |format|
      format.json { render json: race_result }
    end
  end

  # "TAGID"=>" 00 00 00 00 00 00 00 00 00 01 65 19",
  # "RSSI"=>"60",
  # "TIME"=>"14.08.2017 13:07:14.36753 %2B02:00",
  # "RACEID"=>5
  def from_device
    race = Race.find(params[:RACEID])
    start_number = StartNumber.find_by!(tag_id: params[:TAGID].strip)

    race_result = RaceResult.find_by(race: race, start_number: start_number)
    millis = DateTime.strptime(params[:TIME], '%d.%m.%Y %H:%M:%S.%L %:z').to_f

    race_result.lap_times << millis
    race_result.status = 3
    race_result.save!

    data = {
      finish_time: race_result.finish_time,
      racer_name: race_result.racer.full_name,
      start_number: race_result.start_number.value,
      tag_id: race_result.start_number.tag_id
    }

    render json: data
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race_result
      @race_result = RaceResult.find(params[:id])
    end

    def set_start_number
      if params[:start_number]
        @start_number = StartNumber.find_by(race_id: params[:race_id], value: params[:start_number])
        @start_number = StartNumber.find_by(value: params[:start_number]) if @start_number.nil?
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def race_result_params
      params.require(:race_result).permit(:racer_id, :race_id, :status, :lap_times, :category_id)
    end
end

class RaceResultsController < ApplicationController
  before_action :set_race_result, only: %i[show edit update destroy]
  before_action :check_admin, only: %i[index show new from_timing destroy_from_timing]
  before_action :set_start_number, only: %i[from_timing destroy_from_timing from_climbing]

  protect_from_forgery except: %i[from_device from_climbing]

  # GET /race_results
  # GET /race_results.json
  def index
    @race_results = RaceResult.all
  end

  # GET /race_results/1
  # GET /race_results/1.json
  def show; end

  # GET /race_results/new
  def new
    @race_result = RaceResult.new
  end

  # GET /race_results/1/edit
  def edit; end

  # POST /race_results
  # POST /race_results.json
  def create
    @race_result = RaceResult.new(race_result_params)

    respond_to do |format|
      if @race_result.save
        send_email
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
    category_id = params[:race_result][:category_id]
    if start_number_val.present?
      start_number = @race_result.race.pool.start_numbers.find_by!(value: start_number_val)
      raise 'Start number not found' if start_number.nil?
      @race_result.update!(start_number: start_number)
    end

    if category_id.present?
      @race_result.update!(category_id: category_id)
    end

    if race_result_params[:lap_times]
      @race_result.update!(lap_times: JSON.parse(race_result_params[:lap_times]))
    end

    respond_to do |format|
      format.html { redirect_to @race_result.race, notice: 'Uplata uspjesno zaprimljena.' }
      format.json { render :show, status: :ok, location: @race_result }
    end
  end

  # DELETE /race_results/1
  # DELETE /race_results/1.json
  def destroy
    race = @race_result.race
    raise 'Odjave su zakljucane!' unless current_user.admin? || !race.lock_race_results
    @race_result.destroy

    respond_to do |format|
      format.html { redirect_to race, notice: 'Odjava je bila uspjesna.' }
      format.json { head :no_content }
    end
  end

  # POST /race_results/from_timing
  def from_timing
    race_result = RaceResult.find_by!(race: @race, start_number: @start_number)
    race_result.lap_times << params[:time].to_f / 1000 if params[:time]
    race_result.status = params[:status]
    race_result.save!
    respond_to do |format|
      format.json { render json: race_result }
    end
  end

  # DELETE /race_results/destroy_from_timing
  def destroy_from_timing
    race_result = RaceResult.find_by(race_id: params[:race_id], start_number: @start_number)
    race_result.lap_times -= [(params[:time].to_f / 1000).to_s]
    race_result.save!
    respond_to do |format|
      format.json { render json: race_result }
    end
  end

  def from_climbing
    raise 'Not Found' if @start_number.nil?
    race_result = RaceResult.find_by!(race_id: params[:race_id], start_number: @start_number)
    climbs = race_result.climbs
    climbs[params[:level]] = {
      points: params[:points],
      time: params[:time]
    }
    race_result.update!(climbs: climbs)
    render json: race_result
  end

  # "TAGID"=>" 00 00 00 00 00 00 00 00 00 01 65 19",
  # "RSSI"=>"60",
  # "TIME"=>"14.08.2017 13:07:14.36753 %2B02:00",
  # "RACEID"=>5,6,7
  def from_device
    reader_id = params[:READERID]
    race_ids = params[:RACEID].split(',')
    pool_ids = Race.select(:pool_id, :id).find(race_ids).pluck(:pool_id).uniq
    start_number = StartNumber.find_by(pool_id: pool_ids, tag_id: params[:TAGID].strip)
    start_number = StartNumber.find_by(pool_id: pool_ids, alternate_tag_id: params[:TAGID].strip) if start_number.nil?

    if start_number.nil?
      data = {
        error: 'Tag not in database',
        tag_id: params[:TAGID],
        race_id: params[:RACEID]
      }
      return render json: data
    end

    race_result = RaceResult.find_by(race_id: race_ids, start_number: start_number)
    if race_result.race.ended_at
      data = {
        error: 'Race ended',
        tag_id: params[:TAGID],
        race_id: params[:RACEID]
      }
      return render json: data
    end

    millis = DateTime.strptime(params[:TIME], '%d.%m.%Y %H:%M:%S.%L %:z').to_f

    race_result.lap_times << { time: millis, reader_id: reader_id }
    race_result.status = 3
    race_result.save!

    data = {
      finish_time: race_result.finish_time,
      racer_name: race_result.racer.full_name,
      start_number: race_result.start_number.value,
      tag_id: race_result.start_number.tag_id,
      alternate_tag_id: race_result.start_number.alternate_tag_id
    }

    render json: data
  end

  private

  def check_admin
    race_id = @race_result&.race_id || params[:race_id]
    fail 'Access denied' unless current_user.admin? || race_admin?(race_id)
  end

  def set_race_result
    @race_result = RaceResult.find(params[:id])
  end

  def set_start_number
    @race = Race.find(params[:race_id])
    @start_number = @race.pool.start_numbers.find_by!(value: params[:start_number])
  end

  def race_result_params
    params.require(:race_result).permit(
      :racer_id, :race_id, :status, :lap_times, :category_id, :climbs
    )
  end

  def send_email
    if @race_result.race.send_email
      RacerMailer.race_details(
        @race_result.racer,
        @race_result.race
      ).deliver_later
    end
  end
end

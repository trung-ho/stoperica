class RacesController < ApplicationController
  before_action :set_race, only: [:show, :edit, :update, :destroy, :add_racer]
  before_action :check_race_result, only: [:show]
  before_action :only_admin, only: [:new, :edit, :destroy]

  # GET /races
  # GET /races.json
  def index
    @races = Race.all.order(date: :desc)
  end

  # GET /races/1
  # GET /races/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json do
        render json: @race,
               include: [
                 { race_results: { include: [{ racer: { include: :club } }, :category], methods: [:finish_time] } },
                 categories: { methods: [:started?, :started_at] }
               ]
      end
      format.csv { send_data @race.to_csv }
    end
  end

  def get_live
    race = Race.where.not(started_at: nil).where(ended_at: nil).first
    render json: race
  end

  # GET /races/new
  def new
    @race = Race.new
  end

  # GET /races/1/edit
  def edit
  end

  # POST /races
  # POST /races.json
  def create
    @race = Race.new(race_params)

    respond_to do |format|
      if @race.save
        format.html { redirect_to @race, notice: 'Race was successfully created.' }
        format.json { render :show, status: :created, location: @race }
      else
        format.html { render :new }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /races/1
  # PATCH/PUT /races/1.json
  def update
    if params[:started_at].present? && @race.started_at.nil?
      @race.started_at = Time.at(params[:started_at].to_i / 1000)
    end
    @race.ended_at = Time.at(params[:ended_at].to_i / 1000) if params[:ended_at].present?
    @race.save!

    @race.assign_positions if params[:ended_at].present? && @race.ended_at

    if params[:started_at].present? && params[:categories].present?
      start_time = Time.at(params[:started_at].to_i / 1000)
      @race.race_results.where(category_id: params[:categories]).update(started_at: start_time)
      @race.update!(ended_at: nil)
    end

    respond_to do |format|
      if @race.update(race_params)
        format.html { redirect_to @race, notice: 'Race was successfully updated.' }
        format.json { render :show, status: :ok, location: @race }
      else
        format.html { render :edit }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /races/1
  # DELETE /races/1.json
  def destroy
    @race.destroy
    respond_to do |format|
      format.html { redirect_to races_url, notice: 'Race was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_racer
    @race.racers << current_user.racer
    redirect_to @race
  end

  private

  def set_race
    if action_name == 'show'
      @race = Race.includes(race_results: { racer: :club }).find(params[:id])
    else
      @race = Race.find(params[:id])
    end
  end

  def race_params
    params.require(:race).permit(
      :name, :date, :laps, :easy_laps, :description_url, :send_email,
      :registration_threshold, :categories, :email_body, :lock_race_results,
      :uci_display
    )
  end

  def check_race_result
    has_race_result = current_user&.racer&.races&.include?(@race)
    @racer_has_race_result = has_race_result
    if has_race_result
      @race_result = current_user.racer.race_results.where(race: @race).first
    end
  end
end

class RacesController < ApplicationController
  before_action :set_race, only: [:show, :embed, :edit, :update, :destroy, :assign_positions, :export]
  before_action :check_race_result, only: [:show]
  before_action :only_admin, only: [:new, :edit, :destroy, :assign_positions]


  # Order is:
  #   Upcoming -> asc
  #   Finished -> desc
  # Uncharacteristic? I know... But client is alway right!
  def index
    @banner = false
    if user_signed_in? && current_user.admin?
      races = Race.where("date >= now()").order(date: :asc)
      races += Race.where("date < now()").order(date: :desc)
    else
      races = Race.where.not(hidden: true).where("date >= now()").order(date: :asc)
      races += Race.where.not(hidden: true).where("date < now()").order(date: :desc)
    end
    @races = Kaminari.paginate_array(races).page(params[:page]).per(Race::PAGINATE_PER)
  end

  # GET /races/1
  # GET /races/1.json
  def show
    @banner = false
    @is_admin = current_user&.admin?
    @is_race_admin = race_admin?(@race.id)
    @country_count = @race.racers.group(:country).order('count_all desc').count
    @total_shirts_assigned = @race.race_results.joins(:start_number).count

    if @is_club_admin = @current_racer&.club_admin?
      @club_racers = Racer.where.not(
        id: Racer.joins(:race_results).where('race_results.race_id = ?', @race.id)
          .where(club_id: @current_racer.club_id)
      ).where(club_id: @current_racer.club_id)
    end
    
    if (@is_admin || @is_race_admin) && @race.pool
      @start_numbers = @race.pool.start_numbers.sort_by{|sn| [sn.value.to_i]}.collect{|sn| [sn.value, sn.value]}
    else
      @start_numbers = []
    end

    @race_league = @race.league
    @all_race_results = nil
    @start_box_racers = []
    if @race.not_start_yet? && @race_league && @race_league.races.size > 1 && 
        @race_league.present? && @race_league.league_type == "xczld"
      past_races = @race_league.races.where.not(ended_at: nil).where("id < ?", @race.id)
      if past_races.any?
        @all_race_results = RaceResult.where(race_id: past_races).order(race_id: :desc)
      end

      #start box function
      @start_box_racers = @race.start_box_racers
    end

    respond_to do |format|
      format.html { render :show }
      format.json do
        render json: @race, include: json_includes, methods: :sorted_results
      end
    end
  end

  def export
    ext = params[:format]
    respond_to do |format|
      case params[:type]
      when 'all'
        format.send(ext) { send_data @race.send("to_#{ext}"), filename: "Natjecatelji #{@race.name}.#{ext}" }
      when 'start_list'
        format.send(ext) { send_data @race.send("to_start_list_#{ext}"), filename: "Startna lista #{@race.name}.#{ext}" }
      when 'result'
        format.send(ext) { send_data @race.send("to_results_#{ext}"), filename: "Rezultati #{@race.name}.#{ext}" }
      else
        format.send(ext) { send_data @race.send("to_results_#{ext}", true), filename: "Rezultati #{@race.name}.#{ext}" }
      end
    end
  end

  def embed; end

  def get_live
    race = Race.where.not(started_at: nil).where(ended_at: nil).first
    render json: race
  end

  # GET /races/new
  def new
    @race = Race.new
  end

  # GET /races/1/edit
  def edit; end

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
    @race.update!(race_params)
    if params[:started_at].present? && @race.started_at.nil?
      @race.started_at = Time.at(params[:started_at].to_i / 1000)
    end
    @race.ended_at = Time.at(params[:ended_at].to_i / 1000) if params[:ended_at].present?
    @race.save!

    if params[:ended_at].present? && @race.ended_at
      @race.assign_positions
      @race.assign_points if @race.league&.xczld?
    end

    if params[:started_at].present? && params[:categories].present?
      start_time = Time.at(params[:started_at].to_i / 1000)
      @race.race_results.where(category_id: params[:categories]).update(started_at: start_time)
      @race.update!(ended_at: nil)
    end

    respond_to do |format|
      format.html { redirect_to @race, notice: 'Race was successfully updated.' }
      format.json { render :show, status: :ok, location: @race }
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

  def assign_positions
    @race.assign_positions unless @race.league&.lead?
    @race.assign_points
    @race.adjust_finish_time if @race.road?
    redirect_to @race
  end

  private

  def set_race
    if action_name == 'show'
      @race = Race.includes(:league, :categories, race_results: [{ racer: :club }, :start_number]).find(params[:id])
    else
      @race = Race.find(params[:id])
    end
  end

  def race_params
    params.require(:race).permit(
      :name, :date, :laps, :easy_laps, :description_url, :send_email,
      :registration_threshold, :categories, :email_body, :lock_race_results,
      :uci_display, :race_type, :pool_id, :league_id, :control_points_raw,
      :picture_url, :location_url, :hidden, :started_at, :millis_display,
      :skip_auth, :description_text
    )
  end

  def check_race_result
    # TODO rijesi ovo groblje
    @racer_has_race_result = current_racer&.races&.include?(@race)
    if @racer_has_race_result
      @race_result = current_user.racer.race_results.where(race: @race).first
    end
  end

  def json_includes
    [
      { race_results: race_result_includes },
      categories: { methods: [:started?, :started_at] }
    ]
  end

  def race_result_includes
    personal_fields = [:email, :phone_number, :year_of_birth, :gender, :address,
      :zip_code, :town, :day_of_birth, :month_of_birth, :shirt_size]
    personal_fields = [] if current_user&.admin?
    {
      include: [
        { racer: { include: :club, except: personal_fields } },
        :category,
        :start_number
      ],
      methods: :live_time
    }
  end
end

class RacersController < ApplicationController
  before_action :set_racer, only: %i[edit update destroy]
  before_action :only_admin, only: %i[edit destroy import]
  protect_from_forgery unless: -> { action_name != 'login' && request.format.json? }

  # GET /racers
  # GET /racers.json
  def index
    if user_signed_in? && current_user.admin?
      @racers = Racer.includes(:club).order(id: :desc).page(params[:page])
    else
      @racers = Racer.includes(:club).where.not(hidden: true).order(id: :desc).page(params[:page])
    end
  end

  # GET /racers
  # GET /racers.json
  def search
    term = "%#{params['term']}%"
    @racers = Racer.where('first_name LIKE :term OR last_name LIKE :term OR email LIKE :term', term: term)
    render json: @racers.collect{|r| { id: r.id, full_name: r.full_name } }
  end

  # GET /racers/1
  # GET /racers/1.json
  def show
    @racer = Racer.includes(race_results: [:race, :category]).find(params[:id])
    race_ids = @racer.race_results.pluck :race_id
    @is_race_admin = race_admin? race_ids
  end

  # GET /racers/new
  def new
    @racer = Racer.new
  end

  # GET /racers/1/edit
  def edit
  end

  # POST /racers
  # POST /racers.json
  def create
    unless verify_recaptcha || (user_signed_in? && current_user.admin?)
      redirect_to new_racer_url, notice: 'Recaptcha fail.'
      return
    end
    @racer = Racer.new(racer_params)

    respond_to do |format|
      if @racer.save
        @racer.update!(
          user: User.create!(
            email: @racer.email,
            password: Digest::SHA1.hexdigest(@racer.to_s)
          )
        )
        RacerMailer.welcome(@racer).deliver_later
        if user_signed_in?
          format.html { redirect_to @racer, notice: 'Racer was created.' }
        else
          sign_in @racer.user
          format.html { redirect_to races_path }
        end

        format.json { render :show, status: :created, location: @racer }
      else
        format.html { render :new }
        format.json { render json: @racer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /racers/1
  # PATCH/PUT /racers/1.json
  def update
    respond_to do |format|
      if @racer.update(racer_params)
        format.html { redirect_to @racer, notice: 'Racer was updated.' }
        format.json { render :show, status: :ok, location: @racer }
      else
        format.html { render :edit }
        format.json { render json: @racer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /racers/1
  # DELETE /racers/1.json
  def destroy
    @racer.destroy
    respond_to do |format|
      format.html { redirect_to racers_url, notice: 'Racer was destroyed.' }
      format.json { head :no_content }
    end
  end

  def login
    filter = {
      email: racer_params[:email],
      phone_number: racer_params[:phone_number]
    }
    racer = Racer.find_by(filter)

    if racer.present?
      sign_in racer.user

      respond_to do |format|
        format.html { redirect_to(params[:redirect] || races_path) }
        format.json { render json: racer, include: :races }
      end
    else
      respond_to do |format|
        format.html { redirect_to login_racers_path, notice: 'Nije uspjelo. Pokusaj opet.' }
        format.json { render json: {}, status: 401 }
      end
    end
  end

  def import
    file = params[:file]
    race_id = params[:race_id]
    race = Race.find race_id
    category = race.categories.first
    CSV.foreach(file.path, headers: true) do |row|
      r = row.to_h
      dob = r['DATE_OF_BIRTH'].split('/')
      RaceResult.transaction do
        club = Club.find_or_create_by(code: r['CLUB_CODE'], name: r['CLUB'], category: Club.categories[:pro])
        racer = Racer.find_or_create_by(uci_id: r['UCI_ID']) do |racer|
          racer.first_name = r['FIRST_NAME']
          racer.last_name = r['LAST_NAME']
          racer.email = "#{r['LAST_NAME']}_#{r['FIRST_NAME']}@stoperica.live"
          racer.phone_number = Digest::SHA1.hexdigest(racer.email)
          racer.hidden = true
          racer.gender = 2
          racer.month_of_birth = dob[0]
          racer.day_of_birth = dob[1]
          racer.year_of_birth = dob[2]
          racer.club_id = club.id
          racer.country = Country.find_country_by_ioc(r['NATIONALITY'])&.alpha2
        end
        RaceResult.find_or_create_by(racer: racer, race_id: race_id, category: category, status: 1)
      end
    end
    redirect_to race_path(race_id)
  end

  private

  def set_racer
    @racer = Racer.find(params[:id])
  end

  def racer_params
    params.require(:racer).permit(:first_name, :last_name, :year_of_birth,
      :gender, :email, :phone_number, :club_id, :address, :zip_code, :town,
      :day_of_birth, :month_of_birth, :shirt_size, :uci_id, :country,
      :hidden, :is_biker, :personal_best_hours, :personal_best_minutes,
      :personal_best_seconds, :category)
  end
end

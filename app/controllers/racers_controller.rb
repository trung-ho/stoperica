class RacersController < ApplicationController
  before_action :set_racer, only: [:show, :edit, :update, :destroy]

  # GET /racers
  # GET /racers.json
  def index
    @racers = Racer.all
  end

  # GET /racers/1
  # GET /racers/1.json
  def show
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
    @racer = Racer.new(racer_params)
    @racer.user = User.create!(email: @racer.email, password: 'mtb4life')

    respond_to do |format|
      if @racer.save
        if user_signed_in?
          format.html { redirect_to @racer, notice: 'Racer was successfully created.' }
          format.json { render :show, status: :created, location: @racer }
        else
          sign_in @racer.user
          format.html { redirect_to races_path }
          format.json { render :show, status: :created, location: @racer }
        end
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
        format.html { redirect_to @racer, notice: 'Racer was successfully updated.' }
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
      format.html { redirect_to racers_url, notice: 'Racer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def login
    sign_in Racer.where(year_of_birth: racer_params[:year_of_birth], phone_number: racer_params[:phone_number]).first.user and redirect_to races_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_racer
      @racer = Racer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def racer_params
      params.require(:racer).permit(:first_name, :last_name, :year_of_birth, :gender, :email, :phone_number)
    end
end
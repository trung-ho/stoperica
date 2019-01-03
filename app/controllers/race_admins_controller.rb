class RaceAdminsController < ApplicationController
  before_action :only_admin
  before_action :set_race_admin, only: [:show, :edit, :update, :destroy]

  # GET /race_admins
  # GET /race_admins.json
  def index
    @race_admins = RaceAdmin.all
  end

  # GET /race_admins/1
  # GET /race_admins/1.json
  def show
  end

  # GET /race_admins/new
  def new
    @race_admin = RaceAdmin.new
  end

  # GET /race_admins/1/edit
  def edit
  end

  # POST /race_admins
  # POST /race_admins.json
  def create
    @race_admin = RaceAdmin.new(race_admin_params)

    respond_to do |format|
      if @race_admin.save
        format.html { redirect_to @race_admin, notice: 'Race admin was successfully created.' }
        format.json { render :show, status: :created, location: @race_admin }
      else
        format.html { render :new }
        format.json { render json: @race_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /race_admins/1
  # PATCH/PUT /race_admins/1.json
  def update
    respond_to do |format|
      if @race_admin.update(race_admin_params)
        format.html { redirect_to @race_admin, notice: 'Race admin was successfully updated.' }
        format.json { render :show, status: :ok, location: @race_admin }
      else
        format.html { render :edit }
        format.json { render json: @race_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /race_admins/1
  # DELETE /race_admins/1.json
  def destroy
    @race_admin.destroy
    respond_to do |format|
      format.html { redirect_to race_admins_url, notice: 'Race admin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_race_admin
      @race_admin = RaceAdmin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def race_admin_params
      params.require(:race_admin).permit(:racer_id, :race_id)
    end
end

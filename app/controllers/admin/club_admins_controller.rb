class Admin::ClubAdminsController < Admin::AdminController

  def index
    @club_admins = Racer.club_admins.includes(:club)
  end

  def new
    @club_admin = Racer.new
  end

  def create
    @club_admin = Racer.find params[:id]
    if @club_admin.update_attributes(club_admin: true)
      flash[:success] = "Successfully made #{@club_admin.full_name} Club admin!"
      redirect_to admin_club_admins_path
    else
      render :new
    end
  end

  def show
    @club_admin = Racer.find params[:id]
  end

  def destroy
    @club_admin = Racer.find params[:id]
    @club_admin.update_attributes(club_admin: false)
    flash[:success] = "Successfully removed #{@club_admin.full_name} from the list of Club admins!"
    redirect_to admin_club_admins_path
  end


  private

    def club_admin_params
      params.require(:racer).permit(:club_admin)
    end

end

class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exceptions
  before_action :current_racer, if: :current_user

  protected

    def only_admin
      unless current_user&.admin?
        flash[:error] = "You are not authorized to access these resources!"
        redirect_to root_path
      end
    end

    def race_admin? race_id
      return false unless user_signed_in?
      RaceAdmin.exists?(race_id: race_id, racer_id: current_user&.racer&.id)
    end

    def current_racer
      return @current_racer if defined? @current_racer
      @current_racer = current_user&.racer
    end
end

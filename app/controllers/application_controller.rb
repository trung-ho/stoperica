class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def only_admin
    fail 'Access denied' unless current_user&.admin?
  end

  def race_admin? race_id
    RaceAdmin.exists?(race_id: race_id, racer_id: current_user&.racer&.id)
  end
end

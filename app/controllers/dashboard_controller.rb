class DashboardController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:timesync]

  def index
    if current_user.admin?
      @races = Race.all
    else
      @races = RaceAdmin.where(racer_id: current_user.racer_id).collect(&:race)
    end
  end

  def timesync
    ts = {
      jsonrpc: '2.0',
      id: params[:id],
      result: (DateTime.now.to_f * 1000).to_i
    }
    render json: ts
  end
end

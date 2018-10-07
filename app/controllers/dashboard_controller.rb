class DashboardController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:timesync]

  before_action :only_admin, only: [:index]

  def certbot
    render plain: 'GNY2fdOrPES30fZ3L_PWuQxR9OdQaZRJjrHoTYSj_N0.lbHyykbnulS06xq8vXx1F8lSSc1pPx-yL-IlyNKpEY0'
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

class HealthController < ApplicationController
  def ping
    render json: { ok: true, time: Time.now.utc }
  end
end

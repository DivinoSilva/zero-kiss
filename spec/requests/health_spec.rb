require "rails_helper"

RSpec.describe "Health", type: :request do
  it "returns ok" do
    get "/healthz"
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json).to include("ok" => true)
    expect(json).to have_key("time")
  end
end

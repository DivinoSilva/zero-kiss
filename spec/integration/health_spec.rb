require "swagger_helper"

RSpec.describe "Health", swagger_doc: "v1/swagger.yaml" do
  path "/healthz" do
    get "Health check" do
      tags "Health"
      produces "application/json"
      response "200", "ok" do
        run_test!
      end
    end
  end
end

class ApplicationController < ActionController::API
  include ErrorResponse

  rescue_from ActiveRecord::StatementInvalid do |e|
    if e.cause.is_a?(PG::ExclusionViolation)
      render json: { errors: { base: ["frames cannot touch or overlap"] } }, status: :unprocessable_entity
    else
      raise e
    end
  end
end

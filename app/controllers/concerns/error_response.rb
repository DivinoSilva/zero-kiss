# frozen_string_literal: true

module ErrorResponse
  def render_404!
    render json: { error: 'not found' }, status: :not_found
  end

  def render_422!(record)
    render json: { errors: record.errors.to_hash(true) }, status: :unprocessable_entity
  end
end
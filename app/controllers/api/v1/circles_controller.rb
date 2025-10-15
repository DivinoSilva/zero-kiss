# frozen_string_literal: true

module Api
  module V1
    class CirclesController < ApplicationController
      before_action :set_circle, only: %i[update destroy]

      def index
        rel   = Circles::SearchQuery.call(search_params)
        page  = page_param
        limit = per_page_param

        rel = rel.limit(limit).offset((page - 1) * limit)
        render json: rel, each_serializer: CircleSerializer, status: :ok
      end

      def create
        frame = Frame.find(params[:frame_id])
        circle = frame.circles.build(circle_params)

        frame.with_lock do
          if circle.save
            render json: circle, serializer: CircleSerializer, status: :created
          else
            render json: { errors: circle.errors.to_hash(true) }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "not found" }, status: :not_found
      end

      def update
        @circle.frame.with_lock do
          if @circle.update(circle_params)
            render json: @circle, serializer: CircleSerializer, status: :ok
          else
            render json: { errors: @circle.errors.to_hash(true) }, status: :unprocessable_entity
          end
        end
      end

      def destroy
        @circle.frame.with_lock { @circle.destroy! }
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: "not found" }, status: :not_found
      end

      private

      def set_circle
        @circle = Circle.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "not found" }, status: :not_found
      end

      def circle_params
        params.require(:circle).permit(:center_x, :center_y, :diameter)
      end

      def search_params
        params.permit(:frame_id, :center_x, :center_y, :radius)
      end

      def page_param
        params.fetch(:page, 1).to_i.clamp(1, 10_000)
      end

      def per_page_param
        params.fetch(:per_page, 50).to_i.clamp(1, 200)
      end
    end
  end
end

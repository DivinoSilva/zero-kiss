# frozen_string_literal: true

module Api
  module V1
    class FramesController < ApplicationController
      before_action :set_frame, only: %i[show destroy]

      def create
        frame = Frame.new(frame_params)

        Frame.transaction do
          if frame.save
            render json: frame, serializer: FrameSerializer, status: :created
          else
            render json: { errors: frame.errors.to_hash(true) }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      end

      def show
        render json: @frame, serializer: FrameSerializer, status: :ok
      end

      def destroy
        if @frame.destroy
          head :no_content
        else
          render json: { errors: @frame.errors.to_hash(true) }, status: :unprocessable_entity
        end
      end

      private

      def set_frame
        @frame = Frame.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render(json: { error: "not found" }, status: :not_found) && return
      end

      def frame_params
        params.require(:frame).permit(
          :center_x, :center_y, :width, :height,
          circles_attributes: %i[center_x center_y diameter]
        )
      end
    end
  end
end

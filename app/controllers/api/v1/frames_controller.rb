# frozen_string_literal: true

module Api
  module V1
    class FramesController < ApplicationController
      before_action :set_frame, only: %i[show destroy]

      def create
        frame = Frame.new(frame_params)
        if frame.save
          render json: frame, serializer: FrameSerializer, status: :created
        else
          render_422!(frame)
        end
      end

      def show
        render json: @frame, serializer: FrameSerializer, status: :ok
      end

      def destroy
        if @frame.destroy
          head :no_content
        else
          render_422!(@frame)
        end
      end

      private

      def set_frame
        @frame = Frame.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_404!
      end

      def frame_params
        params.require(:frame).permit(:center_x, :center_y, :width, :height)
      end
    end
  end
end

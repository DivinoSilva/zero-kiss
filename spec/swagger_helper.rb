# frozen_string_literal: true
require "rails_helper"

RSpec.configure do |config|
  config.swagger_root = Rails.root.join("swagger").to_s

  config.swagger_docs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "ZeroKiss API",
        version: "v1"
      },
      paths: {},
      components: {
        schemas: {
          Frame: {
            type: :object,
            description: "A frame rectangle in centimeters. Business rule: frames must NOT touch or overlap; violations return 422.",
            properties: {
              id: { type: :integer },
              center_x: { type: :number, format: :float, example: 10.0 },
              center_y: { type: :number, format: :float, example: 10.0 },
              width:    { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 20.0 },
              height:   { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 30.0 }
            },
            required: %i[id center_x center_y width height]
          },
          FrameCreatePayload: {
            type: :object,
            required: ["frame"],
            properties: {
              frame: {
                type: :object,
                required: %w[center_x center_y width height],
                properties: {
                  center_x: { type: :number, format: :float, example: 10.0 },
                  center_y: { type: :number, format: :float, example: 10.0 },
                  width:    { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 20.0 },
                  height:   { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 30.0 }
                },
                description: "If the new frame would touch/overlap another frame, server responds 422."
              }
            }
          },
          Errors422: {
            type: :object,
            properties: {
              errors: {
                type: :object,
                additionalProperties: { type: :array, items: { type: :string } }
              }
            },
            required: ["errors"],
            example: { errors: { base: ["frames cannot touch or overlap"] } }
          },
          Error: {
            type: :object,
            properties: { error: { type: :string, example: "not found" } },
            required: ["error"]
          }
        }
      }
    }
  }

  config.swagger_format = :yaml
end

# frozen_string_literal: true
require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: { title: "ZeroKiss API", version: "v1" },
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
          Circle: {
            type: :object,
            properties: {
              id: { type: :integer },
              frame_id: { type: :integer },
              center_x: { type: :number, format: :float, example: 10.0 },
              center_y: { type: :number, format: :float, example: 10.0 },
              diameter: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 6.0 }
            },
            required: %i[id frame_id center_x center_y diameter]
          },
          CircleCreatePayload: {
            type: :object,
            required: ["circle"],
            properties: {
              circle: {
                type: :object,
                required: %w[center_x center_y diameter],
                properties: {
                  center_x: { type: :number, format: :float },
                  center_y: { type: :number, format: :float },
                  diameter: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true }
                }
              }
            }
          },
          CircleUpdatePayload: {
            type: :object,
            required: ["circle"],
            properties: {
              circle: {
                type: :object,
                properties: {
                  center_x: { type: :number, format: :float },
                  center_y: { type: :number, format: :float },
                  diameter: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true }
                },
                description: "At least one attribute must be present."
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

  config.openapi_format = :yaml
end

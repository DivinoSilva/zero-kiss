# frozen_string_literal: true
require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.3",
      info: {
        title:   "ZeroKiss API",
        version: "v1"
      },
      servers: [
        { url: "http://localhost:3000", description: "local" }
      ],
      paths: {},
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT,
            description: "Paste only the token in the Authorize dialog. The UI will send `Authorization: Bearer <token>` automatically."
          }
        },
        schemas: {
          Error: {
            type: :object,
            properties: { error: { type: :string, example: "not found" } },
            required: ["error"]
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
            example: { errors: { base: ["validation error"] } }
          },

          Frame: {
            type: :object,
            description: "Frame (rectangle in cm). Rule: frames must not touch or overlap. If they do, API returns 422.",
            properties: {
              id:        { type: :integer },
              center_x:  { type: :number, format: :float, example: 10.0 },
              center_y:  { type: :number, format: :float, example: 10.0 },
              width:     { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 20.0 },
              height:    { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 30.0 }
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
                  height:   { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 30.0 },
                  circles_attributes: {
                    type: :array,
                    description: "Nested create in an atomic transaction.",
                    items: {
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
                description: "If the new frame touches or overlaps another, API returns 422."
              }
            }
          },
          Circle: {
            type: :object,
            properties: {
              id:       { type: :integer },
              frame_id: { type: :integer },
              center_x: { type: :number, format: :float },
              center_y: { type: :number, format: :float },
              diameter: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true }
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
                },
                description: "Must fit inside the frame and must not touch or overlap other circles in the same frame."
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
                description: "Same validation rules as create."
              }
            }
          },
          FrameShow: {
            allOf: [
              { "$ref": "#/components/schemas/Frame" },
              {
                type: :object,
                properties: {
                  circles_count:     { type: :integer },
                  topmost_circle:    { oneOf: [{ "$ref": "#/components/schemas/Circle" }, { type: :null }] },
                  bottommost_circle: { oneOf: [{ "$ref": "#/components/schemas/Circle" }, { type: :null }] },
                  leftmost_circle:   { oneOf: [{ "$ref": "#/components/schemas/Circle" }, { type: :null }] },
                  rightmost_circle:  { oneOf: [{ "$ref": "#/components/schemas/Circle" }, { type: :null }] },
                  circles: {
                    type: :array,
                    items: { "$ref": "#/components/schemas/Circle" }
                  }
                }
              }
            ]
          }
        }
      },
      security: [{ bearerAuth: [] }]
    }
  }

  config.openapi_format = :yaml
end

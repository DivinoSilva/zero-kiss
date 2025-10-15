# frozen_string_literal: true
require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.3",
      info: {
        title:       "ZeroKiss API",
        version:     "v1",
        description: "API for Frames and Circles. Frames are axis-aligned rectangles in cm. " \
                     "Circles must fully fit inside their frame and circles within the same frame " \
                     "must not touch or overlap. Frames must not touch or overlap other frames."
      },
      servers: [
        { url: "http://localhost:3000", description: "Local development server" }
      ],
      paths: {},
      components: {
        schemas: {
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: "not found" }
            },
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
            description: "Frame rectangle in cm. Rule: frames must not touch or overlap another frame. Returns 422 on violation.",
            properties: {
              id:        { type: :integer, example: 1 },
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
                    description: "Nested circle creation. All-or-nothing atomic transaction.",
                    items: {
                      type: :object,
                      required: %w[center_x center_y diameter],
                      properties: {
                        center_x: { type: :number, format: :float, example: 0.0 },
                        center_y: { type: :number, format: :float, example: 0.0 },
                        diameter: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 5.0 }
                      }
                    }
                  }
                },
                description: "If the new frame touches or overlaps another frame, returns 422."
              }
            }
          },

          Circle: {
            type: :object,
            properties: {
              id:       { type: :integer, example: 1 },
              frame_id: { type: :integer, example: 1 },
              center_x: { type: :number, format: :float, example: 0.0 },
              center_y: { type: :number, format: :float, example: 0.0 },
              diameter: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 5.0 }
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
                  center_x: { type: :number, format: :float, example: 0.0 },
                  center_y: { type: :number, format: :float, example: 0.0 },
                  diameter: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 2.0 }
                },
                description: "Must fully fit inside the frame and must not touch or overlap any other circle in the same frame."
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
                  center_x: { type: :number, format: :float, example: 1.0 },
                  center_y: { type: :number, format: :float, example: 1.0 },
                  diameter: { type: :number, format: :float, minimum: 0, exclusiveMinimum: true, example: 3.0 }
                },
                description: "Same validations as creation."
              }
            }
          },

          FrameShow: {
            allOf: [
              { "$ref": "#/components/schemas/Frame" },
              {
                type: :object,
                properties: {
                  circles_count:     { type: :integer, example: 3 },
                  topmost_circle:    { "$ref": "#/components/schemas/Circle", nullable: true },
                  bottommost_circle: { "$ref": "#/components/schemas/Circle", nullable: true },
                  leftmost_circle:   { "$ref": "#/components/schemas/Circle", nullable: true },
                  rightmost_circle:  { "$ref": "#/components/schemas/Circle", nullable: true },
                  circles: {
                    type: :array,
                    items: { "$ref": "#/components/schemas/Circle" }
                  }
                }
              }
            ]
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end

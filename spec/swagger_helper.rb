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
            description: "Frame (retângulo em cm). Regra: frames não podem tocar/sobrepor (422).",
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
                    description: "Criação aninhada (transação atômica).",
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
                description: "Se o novo frame tocar/sobrepor outro, retorna 422."
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
                description: "Deve caber no frame e não tocar/sobrepor outros círculos do mesmo frame."
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
                description: "Mesmas regras de validação da criação."
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
                  topmost_circle:    { "$ref": "#/components/schemas/Circle" },
                  bottommost_circle: { "$ref": "#/components/schemas/Circle" },
                  leftmost_circle:   { "$ref": "#/components/schemas/Circle" },
                  rightmost_circle:  { "$ref": "#/components/schemas/Circle" },
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

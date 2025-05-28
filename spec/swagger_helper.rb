
require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Currency Converter API',
        version: 'v1',
        description: 'API for currency conversion and transaction tracking.'
      },
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        },
        {
          url: 'https://{productionHost}',
          variables: {
            productionHost: {
              default: 'localhost:3000' # TODO - update here if after I deploy to flyio
            }
          }
        }
      ],
      components: {
        schemas: {
          error_object: {
            type: 'object',
            properties: {
              message: { type: 'string' }
            }
          },
          transaction: {
            type: 'object',
            properties: {
              transaction_id: { type: 'integer', example: 42 },
              user_id: { type: 'integer', example: 123 },
              from_currency: { type: 'string', example: 'USD' },
              to_currency: { type: 'string', example: 'BRL' },
              from_value: { type: 'number', format: 'float', example: 100.0 },
              to_value: { type: 'number', format: 'float', example: 525.32 },
              rate: { type: 'number', format: 'float', example: 5.2532 },
              timestamp: { type: 'string', format: 'date-time', example: '2024-05-19T18:00:00Z' }
            },
            required: [
              'transaction_id', 'user_id', 'from_currency', 'to_currency',
              'from_value', 'to_value', 'rate', 'timestamp'
            ]
          },
          conversion_request: {
            type: 'object',
            properties: {
              user_id: { type: 'integer', example: 123, description: 'ID of the user performing the conversion.' },
              from_currency: { type: 'string', example: 'USD', enum: [ 'USD', 'BRL', 'EUR', 'JPY' ], description: 'Currency to convert from.' },
              to_currency: { type: 'string', example: 'BRL', enum: [ 'USD', 'BRL', 'EUR', 'JPY' ], description: 'Currency to convert to.' },
              amount: { type: 'number', format: 'float', example: 100.0, description: 'Amount in the original currency.' }
            },
            required: [ 'user_id', 'from_currency', 'to_currency', 'amount' ]
          }
        },
        securitySchemes: {
          # bearer_auth: {
          #   type: :http,
          #   scheme: :bearer
          # }
        }
      }
    }
  }

  config.swagger_format = :yaml
end

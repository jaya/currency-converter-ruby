require 'swagger_helper'

RSpec.describe 'User Login', type: :request do
  path '/login' do
    post 'Authenticate user and start session' do
      tags 'Sessions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :session, in: :body, schema: {
        type: :object,
        properties: {
          session: {
            type: :object,
            properties: {
              email:    { type: :string, description: 'User email address' },
              password: { type: :string, description: 'User password' }
            },
            required: [ 'email', 'password' ]
          }
        },
        required: [ 'session' ]
      }

      response '200', 'login successful' do
        before do
          User.create!(name: 'Joane', email: 'joane@example.com', password: 'secure123')
        end
        let(:session) { { session: { email: 'joane@example.com', password: 'secure123' } } }

        run_test!
      end

      response '401', 'invalid credentials' do
        let(:session) { { session: { email: 'wrong@example.com', password: 'wrong' } } }
        run_test!
      end
    end
  end
end

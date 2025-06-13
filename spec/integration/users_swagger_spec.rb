require 'swagger_helper'

RSpec.describe 'User Registration', type: :request do
  path '/users' do
    post 'Register a new user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name:     { type: :string, example: 'Jane Doe' },
          email:    { type: :string, example: 'jane@example.com' },
          password: { type: :string, example: 'secure123' }
        },
        required: [ 'name', 'email', 'password' ]
      }

      response '201', 'user created' do
        schema type: :object,
                properties: {
                  id:    { type: :integer },
                  name:  { type: :string },
                  email: { type: :string }
                },
                required: [ 'id', 'name', 'email' ]

        let(:user) { { user: { name: 'Jane', email: 'jane@example.com', password: 'secure123' } } }
        run_test!
      end

      response '422', 'invalid input' do
        let(:user) { { user: { name: '', email: '', password: '' } } }
        run_test!
      end

      response '422', 'email already taken' do
        before do
          User.create!(name: 'Jane', email: 'jane@example.com', password: 'secure123')
        end
        let(:user) { { user: { name: 'Jane', email: 'jane@example.com', password: 'anotherpass' } } }
        run_test!
      end
    end
  end
end

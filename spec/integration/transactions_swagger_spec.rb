require 'swagger_helper'

RSpec.describe 'Currency Conversion -Transactions', type: :request do
  path '/transactions/convert' do
    post 'Convert currency' do
      tags 'Transactions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :conversion, in: :body, schema: {
        type: :object,
        properties: {
          from_cur: { type: :string },
          to_cur:   { type: :string },
          from_val: { type: :number }
        },
        required: [ 'from_cur', 'to_cur', 'from_val' ]
      }

      response '201', 'conversion successful' do
        before do
          user = User.create!(name: 'Jane', email: 'jane@example.com', password: 'secure123')
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        end

        let(:conversion) { { from_cur: 'USD', to_cur: 'BRL', from_val: 100.0 } }
        run_test!
      end

      response '400', 'conversion failed' do
        before do
          user = User.create!(name: 'Jane', email: 'jane@example.com', password: 'secure123')
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
        end

        let(:conversion) { { from_cur: 'AAA', to_cur: 'BBB', from_val: 100.0 } }
        run_test!
      end
    end
  end

  path '/transactions' do
    get 'List transactions for user' do
      tags 'Transactions'
      produces 'application/json'
      parameter name: :user_id, in: :query, type: :integer, required: false

      response '200', 'transactions retrieved' do
        schema type: :array, items: {
          type: :object,
          properties: {
            transaction_id: { type: :integer },
            user_id: { type: :integer },
            from_currency: { type: :string },
            to_currency: { type: :string },
            from_value: { type: :number },
            to_value: { type: :number },
            rate: { type: :number },
            timestamp: { type: :string, format: :date_time }
          }
        }

        run_test!
      end
    end
  end
end

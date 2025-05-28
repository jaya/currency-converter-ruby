require "swagger_helper"

describe "Transactions API", type: :request do
  path "/api/v1/transactions" do
    let!(:user) { create(:user) }

    post "Creates a currency conversion transaction" do
      tags "Transactions"
      consumes "application/json"
      produces "application/json"
      parameter name: :conversion_params, in: :body, schema: { "$ref" => "#/components/schemas/conversion_request" }

      response "201_created", "transaction created" do
        schema "$ref" => "#/components/schemas/transaction"

        let(:conversion_params) do
          {
            from_currency: "USD",
            to_currency: "BRL",
            amount: 100.0
          }
        end

        run_test! do |response|
          expect(response.parsed_body).to include(
            {
              "transaction_id": a_kind_of(Integer),
              "user_id" => user.id,
              "from_currency": "USD",
              "to_currency": "BRL",
              "from_value": 100.0,
              "to_value": 525.32,
              "rate": 5.2532,
              "timestamp": a_kind_of(String)
            }
          )
        end
      end

      response "422_unprocessable_entity", "invalid request" do
        schema "$ref" => "#/components/schemas/error_object"
        let(:conversion_params) do
        end
        run_test!
      end

      response "400_bad_request", "bad request" do
        schema "$ref" => "#/components/schemas/error_object"
        run_test!
      end
    end

    get "Lists transactions for a user" do
      tags "Transactions"
      produces "application/json"
      parameter name: :user_id, in: :query, type: :integer, description: "User ID to filter transactions", required: true

      response "200_ok", "transactions list" do
        schema type: :array, items: { "$ref" => "#/components/schemas/transaction" }

        run_test! do |response|
        end
      end

      response "400_bad_request", "user_id parameter missing" do
        schema "$ref" => "#/components/schemas/error_object"
        run_test!
      end

      response "404_not_found", "user not found or no transactions" do
         schema "$ref" => "#/components/schemas/error_object"
         run_test!
      end
    end
  end
end

require "swagger_helper"

describe "Transactions API", type: :request, vcr: true do
  path "/api/v1/transactions" do
    post "Creates a currency conversion transaction" do
      tags "Transactions"
      consumes "application/json"
      produces "application/json"
      parameter name: :conversion_params, in: :body, schema: { "$ref" => "#/components/schemas/conversion_request" }

      response "201", "transaction created" do
        schema "$ref" => "#/components/schemas/transaction"

        let(:conversion_params) do
          {
            conversion_params: {
              user_id: 100,
              from_currency: "USD",
              to_currency: "BRL",
              amount: 100.0
            }
          }
        end

        run_test! do |response|
          expect(response.parsed_body).to include(
            {
              "transaction_id": a_kind_of(Integer),
              "user_id" => 100,
              "from_currency": "USD",
              "to_currency": "BRL",
              "from_value": a_kind_of(Float),
              "to_value": a_kind_of(Float),
              "rate": a_kind_of(Float),
              "timestamp": a_kind_of(String)
            }
          )
        end
      end

      response "422", "invalid request" do
        schema "$ref" => "#/components/schemas/error_object"
        let(:conversion_params) do
          { conversion_params: { user_id: 100, from_currency: "ASD" } }
        end
        run_test!
      end

      response "400", "bad request" do
        schema "$ref" => "#/components/schemas/error_object"
        let(:conversion_params) { }
        run_test!
      end
    end

    get "Lists transactions for a user" do
      let(:user_id) { 100 }
      tags "Transactions"
      produces "application/json"
      parameter name: :user_id, in: :query, type: :integer, description: "User ID to filter transactions", required: false

      response "200", "transactions list" do
        schema type: :array, items: { "$ref" => "#/components/schemas/transaction" }

        run_test! do |response|
        end
      end
    end
  end
end

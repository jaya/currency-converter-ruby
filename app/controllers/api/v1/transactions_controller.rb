class Api::V1::TransactionsController < ApplicationController
  def index
  end

  def create
    mock_response = {
      "transaction_id": 42,
      "user_id": 123,
      "from_currency": "USD",
      "to_currency": "BRL",
      "from_value": 100,
      "to_value": 525.32,
      "rate": 5.2532,
      "timestamp": "2024-05-19T18:00:00Z"
    }

    render json: mock_response, status: :created
  end

  private

  def transaction_params
    params.require(:conversion_params).permit(:user_id, :from_currency, :to_currency, :amount)
  end
end

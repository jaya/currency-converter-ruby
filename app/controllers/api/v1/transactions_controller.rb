class Api::V1::TransactionsController < ApplicationController
  def index
    user_id = params.permit(:user_id)

    transactions =
      if user_id[:user_id].present?
        Transaction.where(user_id: user_id[:user_id])
      else
        Transaction.all
      end

    render json: transactions.map(&:as_json), status: :ok
  end

  def create
    service_params = transaction_params.slice(:from_currency, :to_currency)

    service = CurrencyRateService.new(to_currency: service_params[:to_currency], from_currency: service_params[:from_currency])

    result = service.call

    if result.error?
      render json: { message: result.error_message }, status: :unprocessable_entity
      return
    end

    transaction = Transaction.new(
      user_id: transaction_params[:user_id],
      from_currency: transaction_params[:from_currency],
      to_currency: transaction_params[:to_currency],
      from_value: transaction_params[:amount],
      to_value: result.payload,
      rate: result.payload / transaction_params[:amount],
    )

    if transaction.save
      render json: transaction.as_json, status: :created
    else
      render json: { message: transaction.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.require(:conversion_params).permit(:user_id, :from_currency, :to_currency, :amount)
  end
end

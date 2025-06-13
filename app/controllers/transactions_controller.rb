require "faraday"
require "json"

CUR_API_URL = "https://api.currencyapi.com/v3/latest"

class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]
  before_action :require_login, only: %i[ convert show edit update destroy ]

  # GET /transactions or /transactions.json
  def index
    if current_user
      # If the user is logged in, show only their transactions
      @transactions = Transaction.where(user_id: current_user.id)
    elsif params[:user_id].present?
        # If the request especify the user_id, show only that user's transactions
        @transactions = Transaction.where(user_id: params[:user_id])
    else
        @transactions = Transaction.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json do
        render json: @transactions.map { |t| transaction_json(t) }
      end
    end
  end

  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: "Transaction was successfully created." }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy!

    respond_to do |format|
      format.html { redirect_to transactions_path, status: :see_other, notice: "Transaction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def convert
    from_cur = params[:from_cur]
    to_cur = params[:to_cur]
    from_val = params[:from_val].to_f

    begin
      rate = get_conversion_rate(from_cur, to_cur)
      to_val = from_val * rate

      @transaction = Transaction.new(
        user_id: current_user.id,
        from_cur: from_cur,
        to_cur: to_cur,
        from_val: from_val,
        to_val: to_val,
        rate: rate,
        timestamp: Time.current.utc
      )

      if @transaction.save
        respond_to do |format|
          format.html { redirect_to transactions_path, notice: "Converted #{from_val} #{from_cur} to #{to_val.round(2)} #{to_cur}." }
          format.json do
            render json: transaction_json(@transaction), status: :created
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to root_path, alert: "Conversion failed." }
          format.json { render json: { error: @transaction.errors.full_messages.join(", ") }, status: :unprocessable_entity }
        end
      end
    rescue => e
      Rails.logger.error "Conversion error: #{e.message}"
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Conversion failed: #{e.message}" }
        format.json { render json: { error: "Conversion failed: #{e.message}" }, status: :bad_request }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Transaction not found: #{e.message}"
      redirect_to transactions_path, alert: "Transaction not found."
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.expect(transaction: [ :user_id, :from_cur, :to_cur, :from_val, :to_val, :rate, :timestamp ])
    end

    def require_login
      unless current_user
        respond_to do |format|
          format.html { redirect_to login_path, alert: "You must be logged to convert values." }
          format.json { render json: { error: "You must be logged to convert values." }, status: :unauthorized }
        end
      end
    end

    def get_conversion_rate(from_cur, to_cur)
      api_key = Rails.application.credentials.dig(:currencyapi, :key) || ENV["CURRENCY_API_KEY"]
      raise "API key missing" if api_key.blank?

      return 1.0 if from_cur == to_cur

      url = CUR_API_URL
      response = Faraday.get(url, {
        apikey: api_key,
        currencies: to_cur,
        base_currency: from_cur
      })

      if response.success?
        data = JSON.parse(response.body)
        rate = data.dig("data", to_cur, "value")
        raise "Invalid API response" unless rate
        rate.to_f
      else
        raise "Currency API error: #{response.status} - #{response.body}"
      end
    rescue => e
      Rails.logger.error "Currency API exception: #{e.message}"
      raise "Currency conversion failed: #{e.message}"
      redirect_to root_path, alert: "Conversion failed: #{e.message}"
    end

    def transaction_json(transaction)
    {
      transaction_id: transaction.id,
      user_id: transaction.user_id,
      from_currency: transaction.from_cur,
      to_currency: transaction.to_cur,
      from_value: transaction.from_val.to_f,
      to_value: transaction.to_val.to_f,
      rate: transaction.rate.to_f,
      timestamp: transaction.timestamp&.utc&.iso8601
    }
    end
end

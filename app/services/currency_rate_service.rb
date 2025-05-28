class CurrencyRateService
  class Result
    attr_reader :payload, :error_message
    def initialize(payload: nil, error_message: nil)
      @payload = payload
      @error_message = error_message
    end
    def error?
      !@error_message.nil?
    end
    def self.success(payload)
      new(payload: payload)
    end
    def self.failure(message)
      new(error_message: message)
    end
  end

  BASE_URL = "https://api.currencyapi.com/v3/latest".freeze

  class ConfigurationError < StandardError; end
  class ApiConnectionError < StandardError; end
  class ApiResponseError < StandardError; end
  class DataParsingError < StandardError; end

  def initialize(from_currency:, to_currency:, logger: Rails.logger)
    @logger = logger
    @api_key = ENV["CURRENCY_API_KEY"]
    raise ConfigurationError, "API key CURRENCY_API_KEY is not configured in ENV." unless @api_key && !@api_key.empty?

    @from_currency = from_currency.to_s.upcase
    @to_currency = to_currency.to_s.upcase
  end

  def call
    internal_result = make_api_request
    return internal_result if internal_result.error?

    faraday_response = internal_result.payload
    parse_api_response(faraday_response)
  rescue ConfigurationError, ApiConnectionError, ApiResponseError, DataParsingError => e

    @logger.error "[CurrencyRateService] Error: #{e.class} - #{e.message}"
    Result.failure(e.message)
  rescue StandardError => e
    @logger.error "[CurrencyRateService] Unhandled System Error: #{e.class} - #{e.message} \n#{e.backtrace.first(5).join("\n")}"
    Result.failure("An unexpected system error occurred.")
  end

  private

  def make_api_request
    response = connection.get do |req|
      req.params["base_currency"] = @from_currency
      req.params["currencies"] = @to_currency
      req.headers["apikey"] = @api_key
    end
    Result.success(response)
  rescue Faraday::ConnectionFailed => e
    raise ApiConnectionError, "Connection to CurrencyAPI failed: #{e.message}"
  rescue Faraday::TimeoutError => e
    raise ApiConnectionError, "Request to CurrencyAPI timed out: #{e.message}"
  rescue Faraday::Error => e
    raise ApiConnectionError, "CurrencyAPI Faraday request error: #{e.message}"
  end

  def parse_api_response(faraday_response)
    begin
      parsed_body = JSON.parse(faraday_response.body)
    rescue JSON::ParserError => e
      raise DataParsingError, "Error parsing JSON response from CurrencyAPI: #{e.message}"
    end

    unless faraday_response.success?
      api_error_message = parsed_body&.dig("message") || parsed_body&.dig("errors")&.values&.join(", ") || "Status: #{faraday_response.status}"
      raise ApiResponseError, "CurrencyAPI Error: #{api_error_message}"
    end

    currency_data = parsed_body.dig("data", @to_currency)
    unless currency_data.is_a?(Hash) && currency_data.key?("value")
      raise DataParsingError, "Exchange rate data for #{@to_currency} not found or in unexpected format."
    end

    rate = currency_data["value"].to_f
    Result.success(rate)
  end

  def connection
    Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.use Faraday::FollowRedirects::Middleware if defined?(Faraday::FollowRedirects)
      faraday.options.timeout = 5
      faraday.options.open_timeout = 2
    end
  end
end


# Example usage:
# service = CurrencyRateService.new(from_currency: "USD", to_currency: "BRL")
# result = service.call

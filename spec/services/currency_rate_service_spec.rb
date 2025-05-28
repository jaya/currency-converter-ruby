require "rails_helper"

RSpec.describe CurrencyRateService, vcr: true do
  let(:from_currency) { "USD" }
  let(:to_currency) { "EUR" }

  before do
    allow(Rails.logger).to receive(:warn)
    allow(Rails.logger).to receive(:error)
  end

  describe "#initialize" do
    context "when CURRENCY_API_KEY is configured" do
      it "initializes successfully", vcr: false do
        expect {
          described_class.new(from_currency: from_currency, to_currency: to_currency)
        }.not_to raise_error
      end
    end

    context "when CURRENCY_API_KEY is not configured" do
      before do
        allow(ENV).to receive(:[]).with("CURRENCY_API_KEY").and_return(nil)
      end

      it "raises a ConfigurationError" do
        expect {
          described_class.new(from_currency: from_currency, to_currency: to_currency)
        }.to raise_error(CurrencyRateService::ConfigurationError, "API key CURRENCY_API_KEY is not configured in ENV.")
      end
    end
  end

  describe "#call" do
    subject(:service_call) {
      described_class.new(from_currency: from_currency, to_currency: to_currency).call
    }

    context "when API call is successful for USD to EUR" do
      it "returns a result with the correct exchange rate in payload" do
        VCR.use_cassette("currency_api/usd_to_eur_success") do
          result = service_call
          expect(result.error?).to be false
          expect(result.payload).to be_a(Float)
          expect(result.payload).to be > 0
          expect(result.error_message).to be_nil
        end
      end
    end

    context "when API call is successful for BRL to USD" do
      let(:from_currency) { "BRL" }
      let(:to_currency) { "USD" }
      it "returns a result with the correct exchange rate in payload" do
        VCR.use_cassette("currency_api/brl_to_usd_success") do
          result = service_call
          expect(result.error?).to be false
          expect(result.payload).to be_a(Float)
          expect(result.payload).to be > 0
          expect(result.error_message).to be_nil
        end
      end
    end

    context "when we send a non-existent currency to the API" do
      let(:to_currency) { "NONEXISTENT" }
      it "returns a result with error? true and an error message" do
        VCR.use_cassette("currency_api/to_currency_not_found") do
          result = service_call
          expect(result.error?).to be true
          expect(result.payload).to be_nil
          expect(result.error_message).to eq("CurrencyAPI Error: Validation error")
        end
      end
    end

    context "when network connectivity issues occur (simulated)", vcr: false do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new("TCP connection failed"))
      end
      it "returns a result with error? true and connection error message" do
        result = service_call
        expect(result.error?).to be true
        expect(result.payload).to be_nil
        expect(result.error_message).to eq("Connection to CurrencyAPI failed: TCP connection failed")
      end
    end

    context "when API response is not valid JSON (simulated)", vcr: false do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(
          instance_double(Faraday::Response, success?: true, body: "<html>This is not JSON</html>")
        )
      end
      it "returns a result with error? true and parsing error message" do
        result = service_call
        expect(result.error?).to be true
        expect(result.payload).to be_nil
        expect(result.error_message).to include("Error parsing JSON response from CurrencyAPI")
      end
    end
  end
end

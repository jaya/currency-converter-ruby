require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock

  config.configure_rspec_metadata!

  # IMPORTANT: Filter API keys and sensitive data.
  if ENV["CURRENCY_API_KEY"] && !ENV["CURRENCY_API_KEY"].empty?
    config.filter_sensitive_data("<CURRENCY_API_KEY>") { ENV["CURRENCY_API_KEY"] }
  else

    config.filter_sensitive_data("<CURRENCY_API_KEY>") { "DUMMY_API_KEY_FOR_VCR_FILTERING" }
    puts "Warning: CURRENCY_API_KEY not found in ENV. VCR filtering may not be effective if real keys are used for recording."
  end
end

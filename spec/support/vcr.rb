require 'vcr'
require 'cgi'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('../../fixtures/vcr_cassettes', __FILE__)
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<API_KEY>') { Eventful.api_key }
  config.filter_sensitive_data('<USER_AGENT>') do |interaction|
    interaction.request.headers['User-Agent'].first
  end
  config.default_cassette_options = {
    :serialize_with => :syck
  }
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end
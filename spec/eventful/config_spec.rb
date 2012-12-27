require 'spec_helper'

describe Eventful::Config do

  subject(:config) do
    Eventful::Config.new
  end

  describe '#logger=' do

    it 'sets the provided logger' do
      config.logger = 'zomg'
      config.logger.should eq('zomg')
    end
  end

  describe '#faraday_adapter=' do

    it 'sets the provided adapter' do
      config.faraday_adapter = 'requesty'
      config.faraday_adapter.should eq('requesty')
    end
  end
end
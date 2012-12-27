require 'spec_helper'

describe Eventful do

  describe '.configure' do

    context 'when a block is given' do

      before do
        Eventful.configure do |config|
          config.api_key = 'magic'
        end
      end

      after do
        Eventful.config.reset!
      end

      it 'sets the values on the config instance' do
        Eventful.config.api_key.should eq('magic')
      end
    end

    context 'when a block is not given' do

      it 'returns an Eventful::Config' do
        Eventful.configure.should be_a(Eventful::Config)
      end

      it 'uses .config to retrieve the configuration' do
        Eventful.should_receive(:config).and_return(:foo)
        Eventful.configure.should eq(:foo)
      end
    end
  end

  describe '.config' do

    it 'returns an Eventful::Config' do
      Eventful.config.should be_a(Eventful::Config)
    end

    it 'returns a singleton' do
      Eventful.config.object_id.should eq(Eventful.config.object_id)
    end
  end

  Eventful::Config.public_instance_methods(false).each do |method_name|

    describe ".#{method_name}" do

      it 'delegates to config' do
        Eventful.config.should_receive(method_name)
        Eventful.send(method_name)
      end
    end
  end
end
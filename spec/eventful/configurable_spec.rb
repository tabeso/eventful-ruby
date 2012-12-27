require 'spec_helper'

describe Eventful::Configurable do

  describe '.option' do

    subject(:config) do
      Class.new do
        include Eventful::Configurable
        option :get_out, default: 'nao'
        option :awesome, default: true
        option :lame
      end
    end

    it 'adds the provided default to defaults' do
      config.new.get_out.should eq('nao')
    end

    it 'defines a getter for the option' do
      config.new.should respond_to(:get_out)
    end

    it 'defines a setter for the option' do
      instance = config.new
      instance.get_out = 'someday'
      instance.get_out.should eq('someday')
    end

    it 'defines a checker for the option' do
      instance = config.new
      instance.should be_awesome
      instance.should_not be_lame
    end
  end

  describe '.new' do

    subject(:config) do
      Class.new do
        include Eventful::Configurable
        option :foo, default: 'bar'
      end
    end

    it 'initializes with defaults' do
      config.new.foo.should eq('bar')
    end

    it 'sets the provided options' do
      config.new(foo: 'baz').foo.should eq('baz')
    end
  end

  describe '#[]' do

    subject(:config) do
      Eventful::Config.new(api_key: 'hallo')
    end

    it 'returns the option value' do
      config['api_key'].should eq('hallo')
    end
  end

  describe '#[]=' do

    subject(:config) do
      Eventful::Config.new
    end

    it 'sets the option' do
      config.feed_key = 'bai'
      config.feed_key.should eq('bai')
    end
  end

  describe '#==' do

    subject(:config) do
      Class.new do
        include Eventful::Configurable
        option :name
        option :age
      end
    end

    it 'compares the provided object as a hash' do
      config.new(name: 'Joe Blow', age: 36).should eq(name: 'Joe Blow', age: 36)
    end
  end

  describe '#merge!' do

    subject(:config) do
      Eventful::Config.new
    end

    it 'merges the provided options with itself' do
      config.merge!(api_endpoint: 'nowhere', api_key: 'zomgwtfbbq')
      config.api_endpoint.should eq('nowhere')
      config.api_key.should eq('zomgwtfbbq')
    end
  end

  describe '#reset!' do

    subject(:config) do
      Class.new do
        include Eventful::Configurable
        option :random_sauce, default: 'no sauce'
        option :fancy, default: false
      end
    end

    it 'resets the configured options to defaults' do
      instance = config.new(random_sauce: 'weak sauce', fancy: true)
      instance.reset!
      instance.random_sauce.should eq('no sauce')
      instance.fancy.should eq(false)
    end
  end

  [:to_hash, :settings].each do |method_name|

    describe "##{method_name}" do

      subject(:config) do
        Class.new do
          include Eventful::Configurable
          option :deep_fry_responses, default: true
          option :delete_random_files, default: false
          option :waste_cycles, default: true
        end
      end

      it 'returns a hash of configured options' do
        config.new.to_hash.should eq({
          deep_fry_responses: true, delete_random_files: false, waste_cycles: true
        })
      end
    end
  end
end
require 'spec_helper'

describe Eventful do

  describe '.api_key' do
    it 'is accessible' do
      subject.api_key = 'foo'
      subject.api_key.should == 'foo'
    end
  end

  describe '.feed_key' do
    it 'is accessible' do
      subject.feed_key = 'bar'
      subject.feed_key.should == 'bar'
    end
  end

end

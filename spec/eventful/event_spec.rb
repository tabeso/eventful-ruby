require 'spec_helper'

describe Eventful::Event do
  
  describe '.search' do
    context 'when coordinates are provided' do
      use_vcr_cassette 'events/search/with_coordinates'
      
      subject { Eventful::Event.search(location: '32.746682,-117.162741', within: 25) }
      
      it 'returns an array of events' do
        subject.first.should be_kind_of(Eventful::Event)
      end
      
      it 'should be a success' do
        subject.success? == true
      end
      
      it 'should respond to title' do
        subject.first.title should_not be_nil
      end
      
    end
  end
  
end
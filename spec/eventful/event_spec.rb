require 'spec_helper'

describe Eventful::Event do
  
  describe '.search' do
    context 'when coordinates are provided' do
      subject { Eventful::Event.search(latitude: '123', longitude: '-123') }
      
      it 'returns an array of events' do
        subject.first.should be_kind_of(Eventful::Event)
      end
      
      # its(:response) { should be_success }
    end
  end
  
end
require 'spec_helper'

describe Eventful::Event do

  describe '.search' do
    context 'when coordinates are provided' do
      use_vcr_cassette 'events/search/with_coordinates'

      let(:events) { Eventful::Event.search(location: '32.746682,-117.162741', within: 25) }
      subject { events }

      it 'returns an array of events' do
        subject.should be_kind_of(Array)
        subject.first.should be_kind_of(Eventful::Event)
      end

      it { should be_success }

      context 'the first event' do
        subject { events.first }

        its(:title) { should_not be_nil }
      end
    end
  end
  
  describe '.find' do
    use_vcr_cassette 'events/find/existing'
    
    let(:event_id) { 'E0-001-000278174-6' }
    subject(:event) { Eventful::Event.find(event_id) }
    
    it { should be_kind_of(Eventful::Event) }
    it { should be_success }
    
    its(:title) { should_not be_nil }
    
    context 'a non-existent event' do
      use_vcr_cassette 'events/find/non_existing'

      it 'raises a NotFoundError' do
        expect { Eventful::Event.find('teehee') }.to raise_error(Eventful::NotFoundError)
      end
    end
    
  end

end

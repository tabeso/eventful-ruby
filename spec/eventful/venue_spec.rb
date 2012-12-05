require 'spec_helper'

describe Eventful::Venue do

  describe '.find' do
    use_vcr_cassette 'venues/find/existing'

    # let(:event_id) { 'E0-001-000278174-6' }
    # subject(:event) { Eventful::Event.find(event_id) }

    # it { should be_kind_of(Eventful::Event) }
    # it { should be_success }

    # its(:title) { should_not be_nil }

    context 'an inaccessible venue' do
      use_vcr_cassette 'venues/find/inaccessible'

      it 'raises a PermissionsError' do
        expect { Eventful::Venue.find('V0-001-000163980-8') }.to raise_error(Eventful::PermissionsError)
      end
    end

    context 'a non-existent event' do
      use_vcr_cassette 'events/find/non_existing'

      it 'raises a NotFoundError' do
        expect { Eventful::Event.find('teehee') }.to raise_error(Eventful::NotFoundError)
      end
    end
  end

  describe '.all' do
    subject(:request) { Eventful::Event.all }

    it { should be_kind_of(Eventful::Feed::Request) }
  end

  describe '.updates' do
    subject(:request) { Eventful::Event.updates }

    it { should be_kind_of(Eventful::Feed::Request) }
  end

end

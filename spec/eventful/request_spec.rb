require 'spec_helper'

describe Eventful::Request do

  let(:http) do
    Class.new do
      include Eventful::Request
    end
  end

  let(:url) do
    %r{^http://api.eventful.com/}
  end

  let(:client) do
    http.new
  end

  subject do
    client
  end

  after(:each) do
    WebMock.reset!
  end

  context '#get' do

    subject do
      client.get
    end

    it 'executes a GET request' do
      WebMock.stub_request(:any, /.*/)
      subject
      WebMock.should have_requested(:get, url)
    end

    context 'when request times out' do

      it 'raises a TimeoutError' do
        WebMock.stub_request(:any, /.*/).to_timeout
        expect { subject }.to raise_error(Eventful::TimeoutError)
      end
    end
  end

  context '#post' do

    subject do
      client.post(nil, 'something')
    end

    before(:each) do
      WebMock.stub_request(:any, url)
    end

    it 'executes a POST request with the given data' do
      subject
      WebMock.should have_requested(:post, url).with(body: 'something')
    end
  end

  context '#put' do

    subject do
      client.put(nil, 'something')
    end

    before(:each) do
      WebMock.stub_request(:any, url)
    end

    it 'executes a PUT request with the given data' do
      subject
      WebMock.should have_requested(:put, url).with(body: 'something')
    end
  end

  context '#delete' do

    subject do
      client.delete
    end

    before(:each) do
      WebMock.stub_request(:any, url)
    end

    it 'executes a DELETE request' do
      subject
      WebMock.should have_requested(:delete, url)
    end
  end

  context '#connection' do

    it 'accepts XML responses' do
      subject.connection.headers[:accept].should eq('text/xml, application/xml')
    end

    it 'sets the user agent' do
      subject.connection.headers[:user_agent].should eq(http.user_agent)
    end
  end

  context '.user_agent' do

    it 'returns a user agent containing the release, Ruby, and platform versions' do
      http.user_agent.should =~ %r{^eventful-ruby/[0-9\.]+ \(Rubygems; Ruby [0-9\.]+ .+\)$}
    end
  end
end

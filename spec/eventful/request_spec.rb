require 'spec_helper'

describe Eventful::Request do
  let(:http) do
    Class.new do
      include Eventful::Request
    end
  end
  
  let(:url) { %r{^http://api.eventful.com/rest} }

  let(:client) { http.new }

  subject { client }

  after(:each) do
    WebMock.reset!
  end

  context '#get' do
    subject { client.get }

    before(:each) do
      WebMock.stub_request(:any, /.*/)
    end

    it 'should execute a GET request' do
      subject
      WebMock.should have_requested(:get, url)
    end
  end

  context '#post' do
    subject { client.post(nil, 'something') }

    before(:each) do
      WebMock.stub_request(:any, url)
    end

    it 'should execute a POST request with the given data' do
      subject
      WebMock.should have_requested(:post, url).with(:body => 'something')
    end
  end

  context '#put' do
    subject { client.put(nil, 'something') }

    before(:each) do
      WebMock.stub_request(:any, url)
    end

    it 'should execute a PUT request with the given data' do
      subject
      WebMock.should have_requested(:put, url).with(:body => 'something')
    end
  end

  context '#delete' do
    subject { client.delete }

    before(:each) do
      WebMock.stub_request(:any, url)
    end

    it 'should execute a DELETE request' do
      subject
      WebMock.should have_requested(:delete, url)
    end
  end

  context '#connection' do
    it 'should accept XML responses' do
      Faraday::Connection.should_receive(:new).with(hash_including(:headers => hash_including('Accept' => 'text/xml, application/xml; charset=utf-8')))
      subject.connection
    end

    it 'should set the user agent' do
      Faraday::Connection.should_receive(:new).with(hash_including(:headers => hash_including('User-Agent' => subject.user_agent)))
      subject.connection
    end
  end

  context '#user_agent' do
    it 'should build a user agent containing the release, Ruby, and platform versions' do
      subject.user_agent.should =~ %r{^eventful-ruby/[0-9\.]+ \(Rubygems; Ruby [0-9\.]+ .+\)$}
    end
  end
end
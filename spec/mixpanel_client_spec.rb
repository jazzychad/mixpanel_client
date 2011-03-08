require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MixpanelClient::Client do
  before :all do
    config = {'api_key' => 'test', 'api_secret' => 'test'}
    @client = MixpanelClient::Client.new(config)
    @uri = Regexp.escape(MixpanelClient::BASE_URI)
  end

  describe '#request' do
    it 'should return an argument error "Wrong number of arguments" if using the deprecated usage' do
      # Stub Mixpanel request
      stub_request(:get, /^#{@uri}.*/).to_return(:body => '{"legend_size": 0, "data": {"series": [], "values": {}}}')

      data = lambda{@client.request(nil, :events, {
        :event    => '["test-event"]',
        :unit     => 'hour',
        :interval =>  24
      })}

      data.should raise_error(ArgumentError)
    end
  end

  describe 'block form' do
    it 'should work without an endpoint' do
      # Stub Mixpanel request
      stub_request(:get, /^#{@uri}.*/).to_return(:body => '{"legend_size": 0, "data": {"series": [], "values": {}}}')

      # No endpoint
      data = @client.request do
        resource 'events'
        event    '["test-event"]'
        unit     'hour'
        interval  24
      end
      data.should == {"data"=>{"series"=>[], "values"=>{}}, "legend_size"=>0}
    end

    it 'should work with an endpoint, method, and type' do
      # Stub Mixpanel request
      stub_request(:get, /^#{@uri}.*/).to_return(:body => '{"events": [], "type": "general"}')

      # With endpoint
      data = @client.request do
        resource 'events/top'
        type     'general'
      end
      data.should == {"events"=>[], "type"=>"general"}
    end

    it 'should create getter methods for given options' do
      @client.resource.should == 'events/top'
      @client.type.should     == 'general'
    end

    it 'should create setter methods for given options' do
      @client.resource 'hi'
      @client.resource.should == 'hi'

      @client.type 'ok'
      @client.type.should == 'ok'
    end
  end

  describe '#hash_args' do
    it 'should return a hashed string alpha sorted by key names.' do
      args              = {:c => 'see', :a => 'aye', :d => 'dee', :b => 'bee'}
      args_alpha_sorted = {:a => 'aye', :b => 'bee', :c => 'see', :d => 'dee'}
      @client.generate_signature(args).should == @client.generate_signature(args_alpha_sorted)
    end
  end

  describe '#to_hash' do
    it 'should return a ruby hash given json as a string' do
      @client.to_hash('{"a" : "aye", "b" : "bee"}').should == {'a' => 'aye', 'b' => 'bee'}
    end
  end

  describe 'resetting options' do
    it 'options should be reset before each request' do
      # Stub Mixpanel request
      stub_request(:get, /^#{@uri}.*/).to_return(:body => '{"events": [], "type": "general"}')

      @client.request do
        resource 'events'
        event    '["test-event"]'
        funnel   'down-the-rabbit-hole'
        name     'ricky-bobby'
        type     'tall-dark-handsome'
        unit     'hour'
        interval  24
        limit     5
        format    'csv'
        bucket    'list'
      end

      MixpanelClient::Client::OPTIONS.each do |option|
        @client.send(option).should_not be_nil
      end

      @client.request do
        resource 'events/properties/top'
      end

      (MixpanelClient::Client::OPTIONS - [:resource]).each do |option|
        @client.send(option).should be_nil
      end
    end
  end
end

describe MixpanelClient::URI do
  describe '.mixpanel' do
    it 'should return a properly formatted mixpanel uri as a string (without an endpoint)' do
      resource, params  = ['events', {:c => 'see', :a => 'aye'}]
      MixpanelClient::URI.mixpanel(resource, params).should == 'http://mixpanel.com/api/2.0/events?a=aye&c=see'
    end
    it 'should return a properly formatted mixpanel uri as a string (with an endpoint)' do
      resource, params  = ['events/top', {:c => 'see', :a => 'aye'}]
      MixpanelClient::URI.mixpanel(resource, params).should == 'http://mixpanel.com/api/2.0/events/top?a=aye&c=see'
    end
  end

  describe '.encode' do
    it 'should return a string with url encoded values.' do
      params = {:hey => '!@#$%^&*()\/"Ü', :soo => "hëllö?"}
      MixpanelClient::URI.encode(params).should == 'hey=%21%40%23%24%25%5E%26%2A%28%29%5C%2F%22%C3%9C&soo=h%C3%ABll%C3%B6%3F'
    end
  end

  describe '.get' do
    it 'should return a string response' do
      stub_request(:get, 'http://example.com').to_return(:body => 'something')
      MixpanelClient::URI.get('http://example.com').should == 'something'
    end
  end
end

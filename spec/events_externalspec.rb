require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

WebMock.allow_net_connect!

describe 'External calls to mixpanel' do
  before :all do
    config = YAML.load_file(File.dirname(__FILE__) + '/../config/mixpanel.yml')
    config.should_not be_nil
    @client = MixpanelClient::Client.new(config)
  end

  describe 'Events' do
    it 'should raise an error for bad requests' do
      data = lambda {
        @client.request do
          resource 'events'
        end
      }
      data.should raise_error(MixpanelClient::URI::HTTPError)
    end

    it 'should return events' do
      data = @client.request do
        resource 'events'
        event    '["test-event"]'
        type     'general'
        unit     'hour'
        interval  24
      end
      data.should_not be_a Exception
    end

    it 'should return events in csv format' do
      data = @client.request do
        resource 'events'
        event    '["test-event"]'
        type     'general'
        unit     'hour'
        interval  24
        format   'csv'
      end
      data.should_not be_a Exception
    end

    it 'should return events with optional bucket' do
      data = @client.request do
        resource 'events'
        event    '["test-event"]'
        type     'general'
        unit     'hour'
        interval  24
        bucket   'test'
      end
      data.should_not be_a Exception
    end

    it 'should return top events' do
      data = @client.request do
        resource 'events/top'
        type     'general'
        limit    10
      end
      data.should_not be_a Exception
    end

    it 'should return names' do
      data = @client.request do
        resource 'events/names'
        type     'general'
        unit     'hour'
        interval  24
        limit    10
      end
      data.should_not be_a Exception
    end

    it 'should return retention' do
      data = @client.request do
        resource 'events/retention'
        event    '["test-event"]'
        type     'general'
        unit     'hour'
        interval  24
      end
      data.should_not be_a Exception
    end

    it 'should return retention in csv format' do
      data = @client.request do
        resource 'events/retention'
        event    '["test-event"]'
        type     'general'
        unit     'hour'
        interval  24
        format   'csv'
      end
      data.should_not be_a Exception
    end
  end
end

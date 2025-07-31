require 'rails_helper'

RSpec.describe LogChannel, type: :channel do
  before do
    # Subscribe to the channel
    subscribe
  end

  describe '#subscribed' do
    it 'successfully subscribes to log_channel' do
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from('log_channel')
    end

    it 'logs subscription message' do
      expect(Rails.logger).to receive(:info).with('[Cable] Subscribed to log_channel')
      subscribe
    end
  end

  describe '#unsubscribed' do
    it 'logs unsubscription message' do
      expect(Rails.logger).to receive(:info).with('[Cable] Unsubscribed from log_channel')
      unsubscribe
    end

    it 'stops streaming when unsubscribed' do
      unsubscribe
      expect(subscription).not_to have_stream_from('log_channel')
    end
  end

  describe 'broadcasting integration' do
    it 'receives broadcasts from LogBroadcaster' do
      test_message = 'Test log message'
      
      expect {
        LogBroadcaster.log(test_message, level: :info)
      }.to have_broadcasted_to('log_channel').with(
        message: match(/\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] INFO : Test log message/)
      )
    end

    it 'formats different log levels correctly' do
      expect {
        LogBroadcaster.log('Error message', level: :error)
      }.to have_broadcasted_to('log_channel').with(
        message: match(/ERROR.*Error message/)
      )
    end

    it 'includes timestamp in broadcast message' do
      expect {
        LogBroadcaster.log('Timestamped message', level: :debug)
      }.to have_broadcasted_to('log_channel').with(
        message: match(/\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]/)
      )
    end
  end
end

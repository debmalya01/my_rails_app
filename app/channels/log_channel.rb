class LogChannel < ApplicationCable::Channel
  def subscribed
    stream_from "log_channel"
    Rails.logger.info "[Cable] Subscribed to log_channel"
  end

  def unsubscribed
    Rails.logger.info "[Cable] Unsubscribed from log_channel"
  end
end

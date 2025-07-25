class LogBroadcaster
  def self.log(message, level: :info)
    level_str = level.to_s.upcase
    timestamped = "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{level_str} : #{message}"
    ActionCable.server.broadcast("log_channel", { message: timestamped })
  end
end
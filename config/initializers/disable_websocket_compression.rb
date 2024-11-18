# config/initializers/disable_websocket_compression.rb

Rails.application.config.after_initialize do
  module ActionCable
    module Connection
      class WebSocket
        alias_method :old_initialize, :initialize

        def initialize(env, event_loop, protocols)
          @extensions = []
          old_initialize(env, event_loop, protocols)
        end
      end
    end
  end
end

# config/clock.rb
require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  every(1.second, 'FetchArduinoDataJob.perform_later') do
    FetchArduinoDataJob.perform_later
  end
end

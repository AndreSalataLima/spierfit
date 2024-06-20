// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails


import { Turbo } from "@hotwired/turbo-rails"
Turbo.start()

import "@hotwired/turbo-rails"
import "@rails/ujs"
Rails.start()
import "controllers"
import "channels"

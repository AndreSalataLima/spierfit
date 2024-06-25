import { Turbo } from "@hotwired/turbo-rails"
Turbo.start()

import Rails from "@rails/ujs"
Rails.start()

import "controllers"
import "channels"
import "chartkick"
import "Chart.bundle"

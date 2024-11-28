import { Application } from "stimulus"
// Start the Stimulus application
const application = Application.start()

// Preload the controllers for faster loading
//load(application)

// Load all controllers
//const context = require.context("controllers", true, /\.js$/)

import "@hotwired/turbo-rails"
import "controllers"
import "channels/multiplayer_channel"
import "channels/chat_channel"
import "channels/application_channel"
import "channels/consumer"
import "stimulus"
import Rails from "@rails/ujs";
Rails.start();
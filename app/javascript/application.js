// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import _ from "lodash";
import "../channels/chat_channel";
import "./hotwired/turbo-rails"
import "controllers"
import "channels"
import Rails from "@rails/ujs";
Rails.start();
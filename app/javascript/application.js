// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
//= require jquery
//= require jquery_ujs
import "@hotwired/turbo-rails"
import "@rails/ujs"
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false

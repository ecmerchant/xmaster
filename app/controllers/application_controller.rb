class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  require 'amazon/ecs'
  require 'peddler'
  require 'nokogiri'
  require 'open-uri'
  require 'gon'

end

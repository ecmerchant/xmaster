class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  require 'amazon/ecs'
  require 'peddler'
  require 'nokogiri'
  require 'open-uri'
  require 'gon'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "users/sign_in", :alert => exception.message
  end

end

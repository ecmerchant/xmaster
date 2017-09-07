class ItemsController < ApplicationController
  require 'amazon/ecs'
  require 'peddler'

  def get
    #@test1 = "Yes"
    #@test1 = params[:test1]
    if request.post? then
      #dat = params[:data]
      #@test1 = dat
      respond_to do |format|
        format.html
        format.js
      end
    end
  end
end

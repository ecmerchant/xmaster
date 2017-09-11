class ItemsController < ApplicationController
  require 'amazon/ecs'
  require 'peddler'

  def get

    logger.debug("\n<=debug\n")
    res = params[:data]
    result = JSON.parse(res)
    logger.debug(result[0][0])
    logger.debug("\ndebug=>\n")
    if request.post? then
      respond_to do |format|
        format.html
        format.js
      end
    end
  end
end

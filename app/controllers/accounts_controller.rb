class AccountsController < ApplicationController
  def regist
    current_email = current_user.email

    if request.post? then
      @account = Account.new
      data = params[:account]
      logger.debug('\n\nDebug')
      logger.debug(data)
      user = Account.find_by(email: current_email)
      if data[:AWSkey] != nil && data[:skey] != nil && data[:sellerId] != nil then
        if user == nil then
          Account.create(
            email: current_user.email,
            AWSkey: data[:AWSkey],
            skey: data[:skey],
            sellerId:data[:sellerId]
          )
        else
          user.AWSkey = data[:AWSkey]
          user.skey = data[:skey]
          user.sellerId = data[:sellerId]
        end
      end
    else
      temp = Account.find_by(email:current_email)
      logger.debug("Account is search!!\n\n")
      logger.debug(Account.select("AWSkey"))
      if temp != nil then
        logger.debug("Account is found")

        @account = Account.find_by(email:current_email)
      else
        @account = Account.new
      end
    end
  end
end

private
def account_params
  params.require(:account).permit(:AWSkey, :skey, :sellerId)
end

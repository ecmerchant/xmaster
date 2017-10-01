class ItemsController < ApplicationController

  require 'csv'
  before_action :authenticate_user!, only: :get

  def get
    res = params[:data]
    @user = current_user.email
    if res != nil then
      logger.debug(current_user.email)
      logger.debug("\n<=debug\n")
      result = JSON.parse(res)

      res = []
      i = 0
      while i < result.length
          url = result[i][0]
          if url != "" && url != nil  then
            charset = nil
            html = open(url) do |f|
              charset = f.charset # 文字種別を取得
              f.read # htmlを読み込んで変数htmlに渡す
            end
            doc = Nokogiri::HTML.parse(html, nil, charset)
            if doc.xpath('//h1[@class="ProductTitle__text"]') != nil then
              title = doc.xpath('//h1[@class="ProductTitle__text"]').text.gsub("\n","")
              auctionID = doc.xpath('//dd[@class="ProductDetail__description"]')[11].text.gsub("\n","")
              auctionID = auctionID.slice(1,auctionID.length)

              condition = doc.xpath('//dd[@class="ProductDetail__description"]')[0].text.gsub("\n","")
              condition = condition.slice(1,condition.length)

              priceType = doc.xpath('//div[@class="Price Price--current"]//dd[@class="Price__value"]')

              if priceType[0] != nil then
                listPrice = priceType[0].text.gsub("\n","")
              else
                listPrice = ""
              end

              priceType = doc.xpath('//div[@class="Price Price--buynow"]//dd[@class="Price__value"]')
              if priceType[0] != nil then
                binPrice = priceType[0].text.gsub("\n","")
              else
                binPrice = ""
              end

              bitnum = doc.xpath('//dd[@class="Count__number"]')[0].text
              bitnum = bitnum.slice(0,bitnum.length-4)

              restTime = doc.xpath('//dd[@class="Count__number"]')[1].text
              restTime = restTime.slice(0,restTime.length-4)
              logger.debug(restTime)

            else
              title = doc.xpath('//h1[@class="ProductTitle__text"]').text.gsub("\n","")
              auctionID = doc.xpath('//dd[@class="ProductDetail__description"]')[11].text.gsub("\n","")
              auctionID = auctionID.slice(1,auctionID.length)
              condition = doc.xpath('//dd[@class="ProductDetail__description"]')[0].text.gsub("\n","")
              condition = condition.slice(1,condition.length)
              listPrice = doc.xpath('//dd[@class="Price__value"]')[0].text.gsub("\n","")
              binPrice = doc.xpath('//dd[@class="Price__value"]')[1].text.gsub("\n","")
            end
          else
            title = ""
            auctionID = ""
            listPrice = ""
            binPrice = ""
            condition = ""
          end

          res[i] = [url,title,auctionID,listPrice,binPrice,condition]
          i += 1
      end
      logger.debug(res[0])
      logger.debug("\ndebug=>\n")
      @result = res
      render json: res
    end
  end

  def upload
    csv_data = CSV.read('app/others/csv/Flat.File.Toys.jp.csv', headers: true)
    #logger.debug(csv_data)
    #header = csv_data
    render json: csv_data
  end

  def set
    res = params[:data]
    logger.debug("\n<=debug\n")
    if res != nil then
      result = JSON.parse(res)
      logger.debug(result)
      res = []
      i = 0
      logger.debug("\ndebug=>\n")
    end
  end

  def login_check
    @user = current_user
  end

end

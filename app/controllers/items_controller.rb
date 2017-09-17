class ItemsController < ApplicationController

  def get
    res = params[:data]
    if res != nil then
      logger.debug("\n<=debug\n")
      result = JSON.parse(res)

      res = []
      i = 0
      while i < result.length
          url = result[i][0]
          if url != ""  then
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

              restTime = doc.xpath('//dd[@class="Count__number"]')[0].text.gsub("\n","")
              restTime = restTime.slice(0,restTime.length)

              priceType = doc.xpath('//div[@class="Price Price--current"]//dd[@class="Price__value"]')
              if priceType != nil then
                listPrice = priceType[0].text.gsub("\n","")
              else
                listPrice = ""
              end
              priceType = doc.xpath('//div[@class="Price Price--buynow"]//dd[@class="Price__value"]')
              if priceType != nil then
                binPrice = priceType[0].text.gsub("\n","")
              else
                binPrice = ""
              end
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
end

class ItemsController < ApplicationController


  def get
    gon.result = ""
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
              listPrice = doc.xpath('//dd[@class="Price__value"]')[0].text.gsub("\n","")
              binPrice = doc.xpath('//dd[@class="Price__value"]')[1].text.gsub("\n","")
            else
              title = doc.xpath('//h1[@class="ProductTitle__text"]').text.gsub("\n","")
              auctionID = doc.xpath('//dd[@class="ProductDetail__description"]')[11].text.gsub("\n","")
              auctionID = auctionID.slice(1,auctionID.length)
              listPrice = doc.xpath('//dd[@class="Price__value"]')[0].text.gsub("\n","")
              binPrice = doc.xpath('//dd[@class="Price__value"]')[1].text.gsub("\n","")
            end

          else
            title = ""
            auctionID = ""
            listPrice = ""
            binPrice = ""
          end
          res[i] = [url,title,auctionID,listPrice,binPrice]
          i += 1
      end
      logger.debug(res[0])
      logger.debug("\ndebug=>\n")
      @result = res
      render json: res
    end
    #if request.post? then
    #  respond_to do |format|
    #    format.html
    #    format.js
    #  end
    #end
  end
end

class ItemsController < ApplicationController

  require 'csv'
  require 'peddler'
  before_action :authenticate_user!, only: :get

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def get
    res = params[:data]
    @user = current_user.email

    csv_data = CSV.read('app/others/csv/Flat.File.Toys.jp.csv', headers: true)
    gon.csv_head = csv_data

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
            if doc.xpath('//p[@class="ptsFin"]')[0] == nil then

              #商品が出品中の場合
              title = doc.xpath('//h1[@class="ProductTitle__text"]').text.gsub("\n","")

              productinfo = doc.xpath('//li[@class="ProductDetail__item"]')

              k = 0
              while k < productinfo.length
                str = productinfo[k].text
                if str.include?("状態") == true then
                  condition = productinfo[k].inner_html.match(/pan>([\s\S]*?)</)[1]
                end
                if str.include?("オークションID") == true then
                  auctionID = productinfo[k].inner_html.match(/pan>([\s\S]*?)<\/dd/)[1]
                end
                k += 1
              end
              k = 0


              priceType = doc.xpath('//div[@class="Price Price--current"]//dd[@class="Price__value"]')
              if priceType[0] != nil then
                listPrice = priceType[0].text.gsub("\n","")
                logger.debug(listPrice)
                if listPrice.include?("（税 0 円）") == true then
                  listPrice = listPrice.gsub(/（税 0 円）/,"")
                  listPrice = CCur(listPrice)
                else
                  listPrice = listPrice.match(/税込([\s\S]*?)円/)[1]
                  listPrice = CCur(listPrice)
                end
              else
                listPrice = 0
              end

              priceType = doc.xpath('//div[@class="Price Price--buynow"]//dd[@class="Price__value"]')
              if priceType[0] != nil then
                binPrice = priceType[0].text.gsub("\n","")
                if binPrice.include?("（税 0 円）") == true then
                  binPrice = binPrice.gsub(/（税 0 円）/,"")
                  binPrice = CCur(binPrice)
                else
                  binPrice = binPrice.match(/税込([\s\S]*?)円/)
                end
              else
                binPrice = 0
              end

              bitnum = doc.xpath('//dd[@class="Count__number"]')[0].text
              bitnum = bitnum.slice(0,bitnum.length-4)

              restTime = doc.xpath('//dd[@class="Count__number"]')[1].text
              restTime = restTime.slice(0,restTime.length-4)

              images = doc.xpath('//div[@class="ProductImage__inner"]')
              image = []

              k = 0

              while k < images.length
                str = images[k].inner_html
                image[k] = str.match(/src="([\s\S]*?)"/)[1]
                k += 1
              end

            else
              #オークションが終了している場合
              logger.debug(i)
              title = doc.xpath('//h1[@property="auction:Title"]')[0].text
              auctionID = doc.xpath('//td[@property="auction:AuctionID"]')[0].text
              condition = doc.xpath('//td[@property="auction:ItemStatus"]')[0].text
              binPrice = ""
              checkTax = doc.xpath('//p[@class="decTxtTaxIncPrice"]')[0].text

              if checkTax != "税0円" then
                listPrice = doc.xpath('//p[@property="auction:Price"]')[0].text
                listPrice = CCur(listPrice)
              else
                listPrice = doc.xpath('//p[@class="decTxtTaxIncPrice"]')[0].text
                listPrice = CCur(listPrice)
              end

              bitnum = doc.xpath('//b[@property="auction:Bids"]')[0].text
              restTime = "終了"
              k = 0
              while k < 3
                image[k] = ""
                k += 1
              end
            end
          else
            title = ""
            auctionID = ""
            listPrice = ""
            binPrice = ""
            condition = ""
            bitnum = ""
            restTime = ""
            k = 0
            image = []
            while k < 3
              image[k] = ""
              k += 1
            end
          end

          res[i] = [url,title,auctionID,listPrice,binPrice,condition,bitnum,restTime,image[0],image[1],image[2]]

          i += 1
      end

      logger.debug("\ndebug=>\n")
      @result = res
      render json: res
    end
  end

  def upload
    logger.debug("\n\n\n")
    logger.debug("Debug Start!")
    current_email = current_user.email
    user = Account.find_by(email: current_email)
    aws = user.AWSkey
    skey = user.skey
    seller = user.sellerId

    res = params[:data]

    #client = MWS.sellers(
    #  primary_marketplace_id: "A1VC38T7YXB528",
    #  merchant_id: seller,
    #  aws_access_key_id: aws,
    #  aws_secret_access_key: skey
    #)
    client = MWS.feeds(
      primary_marketplace_id: "A1VC38T7YXB528",
      merchant_id: seller,
      aws_access_key_id: aws,
      aws_secret_access_key: skey
    )

    res1 = JSON.parse(res)
    #res1 = [["a","b","c"],[1,2,3],["村上","りえ","ネコ"]]

    logger.debug("Pre Feed Content is \n\n")
    logger.debug(res1)

    kk = 0
    feed_body = ""
    while kk < res1.length
      feed_body = feed_body + res1[kk].join("\t")
      feed_body = feed_body + "\n"
      kk += 1
    end

    #feed_body = "テスト"
    logger.debug("\n\nFeed Content Enocoding is \n\n")
    logger.debug(feed_body.encoding)

    new_body = feed_body.encode(Encoding::Windows_31J)
    logger.debug(new_body.encoding)

    #return

    logger.debug("Feed Content is \n\n")
    logger.debug(new_body)

    feed_type = "_POST_FLAT_FILE_LISTINGS_DATA_"
    parser = client.submit_feed(new_body, feed_type)
    doc = Nokogiri::XML(parser.body)

    submissionId = doc.xpath(".//mws:FeedSubmissionId", {"mws"=>"http://mws.amazonaws.com/doc/2009-01-01/"}).text
    logger.debug(doc)
    logger.debug("\n\n")

    process = ""
    err = 0
    while process != "_DONE_" do
      sleep(25)
      list = {feed_submission_id_list: submissionId}
      parser = client.get_feed_submission_list(list)
      doc = Nokogiri::XML(parser.body)
      process = doc.xpath(".//mws:FeedProcessingStatus", {"mws"=>"http://mws.amazonaws.com/doc/2009-01-01/"}).text
      logger.debug(doc)
      err += 1
      if err > 1 then
        break
      end
    end


    parser = client.get_feed_submission_result(submissionId)
    doc = Nokogiri::XML(parser.body)
    logger.debug(doc)
    logger.debug("\n\n")
    #submissionId = doc.match(/FeedSubmissionId>([\s\S]*?)<\/Feed/)[1]
    #parser.parse # will return a Hash object

    res = ["test"]
    render json: res
  end

  def set
    res = params[:data]
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

  def set_csv
    res = params[:data]
    current_email = current_user.email
    csv_data = CSV.read('app/others/csv/Flat.File.Toys.jp.csv', headers: true)
    render json: csv_data
    gon.csv_dd = csv_data
  end

  def login_check
    @user = current_user
  end

  private def CCur(value)
    res = value.gsub(/\,/,"")
    res = res.gsub(/円/,"")
    return res
  end

end

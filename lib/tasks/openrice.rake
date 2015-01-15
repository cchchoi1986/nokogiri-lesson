namespace :openrice do
  desc "Scrape openrice"

  task :scrape => :environment do
    require 'open-uri'
    require 'nokogiri'

    links = []
    

    district_ids = ["1012", "1011", "1020", "1019", "1003", "1013", "l9151", "1016", "1017", "1024", "l9007", "1005", "1004", "1021", "1014", "1015", "1009", "1018", "1007", "1001", "l9006", "1010", "1025", "1023", "1002", "1026", "1022", "1008", "2013", "2032", "2027", "2009", "2015", "2028", "l9008", "2003", "2001", "2002", "2026", "2016", "2024", "2025", "2030", "2031", "2010", "2006", "2029", "2022", "2019", "2007", "2005", "2004", "2008", "2021", "2020", "2011", "2012", "3008", "3013", "3019", "3015", "3016", "3011", "3021", "3009", "3022", "3006", "3007", "3010", "3001", "3002", "3012", "3014", "3004", "3020", "3017", "3018", "3005", "3003", "4002", "4004", "4006", "4005", "4001", "4003", "4011", "4010", "4009"]

    cuisine_id = ["1023", "1010", "1001", "1027", "1012", "1029", "1002", "1026", "1017", "1005", "1028", "1004", "1024", "1013", "1022", "1018", "1014", "1016", "1021", "1011", "1030", "1031", "1008", "1009", "1015", "1003", "1007",'2999','3999','4999','5999']

    price_id = 1..6

    district_ids.each do |district|
      cuisine_id.each do |cuisine|
        price_id.each do |price|
          url = "http://www.openrice.com/en/hongkong/restaurant/sr1.htm?tc=sr1quick&s=1&region=0&inputstrwhat=&cuisine_id=#{cuisine}&price=#{price}&inputstrwhere=&district_id=#{district}"
          document = open(url).read
          html_doc = Nokogiri::HTML(document)
          total_results = html_doc.css('div.P15 > div.rel_pos > div > div.PR15.FL > span:nth-child(3).txt_bold').text().to_i

          total_pages = (total_results / 15.0).ceil
          page_numbers = 1..total_pages
          # page_numbers = 1..17
          page_numbers.each do |page_number|
            # puts page_number
            url2 = "http://www.openrice.com/en/hongkong/restaurant/sr1.htm?page=#{page_number}&region=0&price=#{price}&cuisine_id=#{cuisine}&district_id=#{district}"
            document2 = open(url2).read
            html_doc2 = Nokogiri::HTML(document2)
            target = 'div.rest_block.rel_pos > div:nth-child(1).normal_poiblock > div:nth-child(1).ib > h2:nth-child(1).inline_show.header2.sr1_poi_title > a:nth-child(1).poi_link'
            html_doc2.css(target).each do |f|
              details = f.attr('href')
              scrape_link(details)
              # links = links.push(details)
            end
          end
          # puts url
          # scrape the restaurants urls in this page
          # save new restaurants
          
        end
      end
    end
  end

  def scrape_link(f)
    # puts links
      url3 = 'http://www.openrice.com'+f
      doc3 = open(url3).read
      html_doc3 = Nokogiri::HTML(doc3)

      rtitle = 'div > div > h1 > span > a'
      raddress = 'div > div > div.col > div.ML10.FL > div'
      rphonenumber = 'div.row > div.col.gu8 > div.info_basic_first.border_right_dot > div.col > div:nth-child(6).ML10.FL'
      rpricerange = 'div > div > div > div.FL > div.FL.ML10'
      rtags = 'div > div > div > div > a.hiddenlink'
      racceptedpayment = 'div.or_is_wrapper > div.or_is_content > div.MR10 > div:nth-child(3).border_bottom_dot.PT5.PB5 > div:nth-child(2).FL'
      racceptedpayment2 = 'div.or_is_wrapper > div.or_is_content > div.MR10 > div:nth-child(3).border_bottom_dot.PT5.PB5 > div:nth-child(2).FL > a'
      rseating = 'div.or_is_wrapper > div.or_is_content > div.MR10 > div:nth-child(4).border_bottom_dot.PT5.PB5 > div:nth-child(2).FL'
      rintro = 'div > div > div > div > div.rest_info_desc'
      rdescription = 'div > div > div > div > div.FL.ML0'
      
      ng = Hash.new
      ng["title"] = html_doc3.css(rtitle).text()
      address = html_doc3.css(raddress).text().gsub(/\s\s+/," ")
      if address.include? "Branches"
        ng["address"] = address.slice(5..address.length).split(' Branches')[0]
      else
        ng["address"] = address
      end
      # ng["phonenumber"] = html_doc3.css(rphonenumber).text()
      if not html_doc3.css(rphonenumber).text.to_i == 0
        ng["phonenumber"] = html_doc3.css(rphonenumber).text
      else
        ng["phonenumber"] = nil
      end


      ng["pricerange"] = html_doc3.css(rpricerange).text()
      ng["tags"] = []
      html_doc3.css(rtags).each do |f|
        ng["tags"].push(f.text)
      end
      
      if not html_doc3.css(racceptedpayment2).any?
        ng["acceptedpayment"] = html_doc3.css(racceptedpayment).text().split(",")
      end

      if not html_doc3.css(rseating).text.to_i == 0
        ng["seating"] = html_doc3.css(rseating).text
      else
        ng["seating"] = nil
      end
      ng["intro"] = html_doc3.css(rintro).text()
      ng["description"] = html_doc3.css(rdescription).text().gsub("\r\n\t\t\t\t\t\t\t\t\t\t\t            ",',').gsub("\r\n (Details) \t\t\t\t\t\t\t\t\t\t\t            ",',').split(',')

      puts ng
      
      Restaurant.create(ng)
    # end
  end
end
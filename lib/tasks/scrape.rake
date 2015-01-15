namespace :scrape do
  # this is a description of your task
  # desc "Scrape google finance"

  # # this is your task function
  # task :google_finance => :environment do
  #   # do something
  #   require 'open-uri'
  #   require 'nokogiri'
  #   puts 'hihi world'
  #   url = 'https://www.google.com/finance?q=NASDAQ%3AFB&fstype=ii&ei=AnezVMnnKcSxkAXhr4CgAg'
  #   document = open(url).read
  #   # puts document

  #   html_doc = Nokogiri::HTML(document)


  #   data_format = ["div.id-incinterimdiv > table.gf-table.rgt > tbody > tr > td.lft.lm","div.id-incinterimdiv > table.gf-table.rgt > tbody > tr > td:nth-child(2).r","div.id-incinterimdiv > table.gf-table.rgt > tbody > tr > td:nth-child(3).r","div.id-incinterimdiv > table.gf-table.rgt > tbody > tr > td:nth-child(4).r","div.id-incinterimdiv > table.gf-table.rgt > tbody > tr > td:nth-child(5).r"];

  #   data_format.each do |f|
  #     puts html_doc.css(f).text
  #   end
  # end

  desc "Scrape companies"
  task :make_companies => :environment do
    require 'open-uri'
    require 'csv'

    url = "http://s3.amazonaws.com/nvest/nasdaq_09_11_2014.csv"

    url_data = open(url)

    CSV.foreach(url_data) do |symbol, name|
      puts "#{name}: #{symbol}"
      Company.create(name: "#{name.gsub(/\s+/,"")}", symbol: "#{symbol.gsub(/\s+/,"")}")
      # Company.create(:name => name, :symbol => symbol)
    end
  end


  desc "Scraping Google Finance Fundamentals Data"
  task :google_finance => :environment do
    

    Company.all.each do |company|
      record_data(company)
    end
  end

  def record_data(company)
    require 'open-uri'
    require 'nokogiri'

    url = "http://www.google.ca/finance?q="+company.symbol.upcase+"&fstype=ii"

    document = open(url).read
    html_doc = Nokogiri::HTML(document)

    # columns 
    # puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td.lft.lm").text
    # puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td:nth-child(2).r").text
    # puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td:nth-child(3).r").text
    # puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td:nth-child(4).r").text
    # puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td.r.rm").text

    details = html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td.r.rm")

    if not details.any?
      return
    end

    new_record = company.annualincomes.new

    Annualincome.columns[4..52].each_with_index do |column, index|
      new_record["#{column.name}"] = details[index].text
    end
    new_record.save
  end
end
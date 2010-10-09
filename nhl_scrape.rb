require 'rubygems'
require 'nokogiri'
require 'mechanize'

class NhlScrape

  URL = "http://www.nhl.com/ice/app?service=page&page=playerstats&fetchKey=YYYY2ALLAASAll&viewName=summary&sort=points&pg="

  attr_reader :player_count, :pages, :season, :datestamp

  def initialize(season=2010)
    @season     = season.to_i
    @pages      = count_pages
    @datestamp  = Time.now.strftime('%Y%m%d')
  end

  def count_pages
    page = download_page(1, false)
    page.link_with(:text => 'Last').href.match(/\d{1,2}$/)[0].to_i
  end

  def cache_html(number, page)
    # TODO make dirs, if necessary
    File.open("cache/#{season}/html/#{datestamp}-#{number}.html", 'w') { |f| f.write(page) }
  end

  def download_all
    (1..pages).each do |pg|
      download_page(pg+1)
    end
  end

  def download_page(number=1, cache=true)
    mech = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
    page = mech.get(URL.gsub(/YYYY/,season.to_s)+number.to_s)
    # TODO handle http errors, e.g.: Mechanize::ResponseCodeError: 500 => Net::HTTPInternalServerError
    cache_html(number, page.content) if cache
    page
  end

  def parse_all
    File.delete("cache/#{season}/#{datestamp}.csv") if File.exists?("cache/#{season}/#{datestamp}.csv")
    File.open("cache/#{season}/#{datestamp}.csv", 'w') do |f|
      (1..pages).each {|pg| f << parse_page(pg) + "\n"}
    end
  end

  def parse_page(number=1)
    download_page(number) unless File.exists?("cache/#{season}/html/#{datestamp}-#{number}.html")
    file = File.read("cache/#{season}/html/#{datestamp}-#{number}.html")
    html = Nokogiri::HTML(file)
    table = html.css('#statsTableGoop #roundedBoxaStats table tr')
    players = []
    table.each_with_index do |row,index|
      next if index == 0 # skip header row
      player = []
      player << row.search('a').first['href'].match(/\/ice\/player.htm\?id=(\d+)/)[1]
      row.css('td.statBox').each do |col|
        data = col.content.gsub(/\n|\t/,'')
        player << data unless data.empty?
      end
      players << player.join(',')
    end
    players.join("\n")
  end

end
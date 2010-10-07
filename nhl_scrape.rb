require 'rubygems'
require 'mechanize'

class NhlScrape

  URL = "http://www.nhl.com/ice/app?service=page&page=playerstats&fetchKey=YYYY2ALLAASAll&viewName=summary&sort=points&pg="

  attr_reader :player_count, :pages, :season, :datestamp

  def initialize(season=2010)
    @season     = season.to_i
    @pages      = count_pages
    @datestamp  = Time.now.strftime('%Y%m%d')
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
    cache_page(number, page) if cache
    page
  end

  def count_pages
    page = download_page(1, false)
    page.link_with(:text => 'Last').href.match(/\d{1,2}$/)[0].to_i
  end

  def cache_page(number, page)
    File.open("cache/#{season}/#{datestamp}-#{number}.html", 'w') { |f| f.write(page.content) }
  end

end
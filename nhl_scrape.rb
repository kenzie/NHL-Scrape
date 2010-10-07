require 'rubygems'
require 'mechanize'

class NhlScrape

  URL = "http://www.nhl.com/ice/app?service=page&page=playerstats&fetchKey=YYYY2ALLAASAll&viewName=summary&sort=points&pg="

  attr_reader :player_count, :pages, :season

  def initialize(season=nil)
    @season = season.nil? ? Time.now.year : season.to_i
    @pages = count_pages
  end

  def download_all
    (1..pages).each do |pg|
      download_page(pg+1)
    end
  end

  def download_page(pg=1, cache=true)
    mech = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
    page = mech.get(URL.gsub(/YYYY/,season.to_s)+pg.to_s)
    File.open("cache/#{season}/page-#{pg}.html", 'w') { |f| f.write(page.content) } if cache
    page
  end

  def count_pages
    page = download_page(1, false)
    page.link_with(:text => 'Last').href.match(/\d{1,2}$/)[0].to_i
  end

end
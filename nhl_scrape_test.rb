require 'test/unit'
require 'nhl_scrape'

# TODO use fakeweb to mock nhl.com requests

class NhlScrapeTest < Test::Unit::TestCase

  def setup
    @s = NhlScrape.new(2010)
  end

  def test_season
    assert_equal 2010, @s.season
  end

  def test_datestamp
    assert_equal Time.now.strftime('%Y%m%d'), @s.datestamp
  end

  def test_count_pages
    assert_equal 30, @s.pages
  end

  def test_download_page_1
    @s.download_page(1)
    assert File.exists?("cache/#{@s.season}/#{@s.datestamp}-1.html")
  end

  def test_download_all
    @s.download_all
    assert File.exists?("cache/#{@s.season}/#{@s.datestamp}-#{@s.pages}.html")
  end

end
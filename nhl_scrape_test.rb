require 'test/unit'
require 'nhl_scrape'

# TODO use fakeweb to mock nhl.com requests

class NhlScrapeTest < Test::Unit::TestCase

  def setup
    @s = NhlScrape.new
  end

  def test_count_pages
    assert_equal 30, @s.pages
  end

  def test_download_page_1
    @s.download_page(1)
    assert File.exists?('cache/page1.html')
  end

  def test_download_all
    @s.download_all
    assert File.exists?('cache/page1.html')
    assert File.exists?("cache/page#{@s.pages}.html")
  end

end
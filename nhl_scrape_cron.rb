#!/usr/local/bin/ruby

require 'nhl_scrape'

s = NhlScrape.new(2010)
s.parse_all
#!/usr/bin/ruby

Dir.chdir(File.expand_path(File.dirname(__FILE__)))

require 'nhl_scrape'

s = NhlScrape.new(2011)
s.parse_all

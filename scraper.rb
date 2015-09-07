#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//h3[span[@id="Initial_MPs"]]/following-sibling::table[1]/tr[td]').drop(1).each do |tr|
    tds = tr.css('td')
    data = { 
      name: tds[1].css('a').text,
      wikiname: tds[1].xpath('a[not(@class="new")]/@title').text,
      party: tds[2].text.tidy,
      area: tds[3].text.tidy,
      term: 15,
    }
    # puts data
    ScraperWiki.save_sqlite([:name, :area, :term], data)
  end
end

scrape_list('https://en.wikipedia.org/wiki/15th_Samoan_Parliament')

#! /usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: false

# require 'rexml/document'
# require 'nokogiri'
# require 'ox'
require 'oga'

class ImageInfo
  attr_accessor :url, :width, :height
end

class BookInfo
  attr_accessor :asin, :title, :binding, :author, :publisher, :publicationDate, :images
  def initialize
    @images = {}
  end
end

def get_text(dom, tag)
  if dom.xpath(tag).size.positive?
    dom.xpath(tag)[0].text
  else
    ''
  end
end

def parse_xmls(xmls)
  bookinfos = []
  xmls.each do |xmlstring|
    doc = Oga.parse_xml(xmlstring)
    image_labels = %w[SmallImage MediumImage LargeImage]
    doc.xpath('ItemLookupResponse/Items/Item').each do |item|
      bookinfo = BookInfo.new
      bookinfo.asin = item.xpath('ASIN').text
      bookinfo.title = get_text(item, 'ItemAttributes/Title')
      bookinfo.binding = get_text(item, 'ItemAttributes/Binding')
      bookinfo.author = get_text(item, 'ItemAttributes/Author')
      bookinfo.publisher = get_text(item, 'ItemAttributes/Publisher')
      bookinfo.publicationDate = get_text(item, 'ItemAttributes/PublicationDate')

      image_labels.each do |image_label|
        next unless item.xpath(image_label).size.positive?
        image = ImageInfo.new
        imgtag = item.xpath(image_label)[0]
        image.url = imgtag.xpath('URL').text
        image.width = imgtag.xpath('Width').text.to_i
        image.height = imgtag.xpath('Height').text.to_i
        bookinfo.images[image_label] = image
      end
      bookinfos << bookinfo
    end
  end
  bookinfos
end

def get_xmls
  xmls = []
  Dir.glob('xmls/*.xml').each do |file|
    open(file, 'r') do |io|
      xmls << io.read
    end
  end
  xmls
end

xmls = get_xmls
t = Time.now
bookinfos = parse_xmls(xmls)
duration = (Time.now.to_f - t.to_f)
puts "xml数: #{xmls.size}"
puts "book数: #{bookinfos.size}"
puts "parse時間: #{duration}"

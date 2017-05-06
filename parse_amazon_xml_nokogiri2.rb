#! /usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: false

# require 'rexml/document'
require 'nokogiri'

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
  if dom.css(tag).size.positive?
    dom.css(tag).text
  else
    ''
  end
end

def parse_xmls(xmls)
  bookinfos = []
  xmls.each do |xmlstring|
    doc = Nokogiri::XML(xmlstring)
    image_labels = %w[SmallImage MediumImage LargeImage]
    doc.css('Item').each do |item|
      bookinfo = BookInfo.new
      bookinfo.asin = item.css('ASIN').text
      attr = item.css('ItemAttributes')
      bookinfo.title = get_text(attr, 'Title')
      bookinfo.binding = get_text(attr, 'Binding')
      bookinfo.author = get_text(attr, 'Author')
      bookinfo.publisher = get_text(attr, 'Publisher')
      bookinfo.publicationDate = get_text(attr, 'PublicationDate')

      image_labels.each do |image_label|
        next unless item.css(image_label).size.positive?
        image = ImageInfo.new
        imgtag = item.css(image_label)[0]
        image.url = imgtag.css('URL').text
        image.width = imgtag.css('Width').text.to_i
        image.height = imgtag.css('Height').text.to_i
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

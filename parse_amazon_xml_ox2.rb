#! /usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: false

# require 'rexml/document'
# require 'nokogiri'
require 'ox'

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
  if dom.locate(tag).size.positive?
    dom.locate(tag)[0].text
  else
    ''
  end
end

def parse_xmls(xmls)
  bookinfos = []
  xmls.each do |xmlstring|
    doc = Ox.parse(xmlstring)
    image_labels = %w[SmallImage MediumImage LargeImage]
    doc.locate('ItemLookupResponse/Items/Item').each do |item|
      bookinfo = BookInfo.new
      bookinfo.asin = item.ASIN.text
      attr = item.ItemAttributes
      bookinfo.title = get_text(attr, 'Title')
      bookinfo.binding = get_text(attr, 'Binding')
      bookinfo.author = get_text(attr, 'Author')
      bookinfo.publisher = get_text(attr, 'Publisher')
      bookinfo.publicationDate = get_text(attr, 'PublicationDate')

      image_labels.each do |image_label|
        next unless item.locate(image_label).size.positive?
        image = ImageInfo.new
        imgtag = item.locate(image_label)[0]
        image.url = imgtag.URL.text
        image.width = imgtag.Width.text.to_i
        image.height = imgtag.Height.text.to_i
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
size = (xmls.size / 4).to_i
xmlss = xmls.each_slice(size).to_a
time = Time.now
bookinfoss = []
threads = []
5.times do |i|
  t = Thread.new do
    bookinfos = parse_xmls(xmlss[i])
    bookinfoss << bookinfos
  end
  threads << t
end

threads.each { |t| t.join }

bookinfos = bookinfoss.flatten

duration = (Time.now.to_f - time.to_f)

puts "xml数: #{xmls.size}"
puts "book数: #{bookinfos.size}"
puts "parse時間: #{duration}"

# -*- coding:utf-8 -*-
import time
from lxml import objectify


class ImageInfo:
    def __init__(self):
        self.url = ''
        self.width = ''
        self.height = ''

class BookInfo:
    def __init__(self):
        self.asin = ''
        self.title = ''
        self.binding = ''
        self.author = ''
        self.publisher = ''
        self.publicationDate = ''
        self.images = {}


def getText(dom, tag):
    return getattr(dom, tag).text if tag in dom else ''


def parseXmls(xmls):
    bookInfos = []
    for xml in xmls:
        dom = objectify.fromstring(xml)
        for item in dom.Items.Item:
            bookInfo = BookInfo()
            bookInfo.asin = item.ASIN.text

            attr = item.ItemAttributes
            bookInfo.title = getText(attr, 'Title')
            bookInfo.binding = getText(attr, 'Binding')
            bookInfo.author = getText(attr, 'Author')
            bookInfo.publisher = getText(attr, 'Publisher')
            bookInfo.publicationDate = getText(attr, 'PublicationDate')

            imageLabels = ['SmallImage', 'MediumImage', 'LargeImage']
            for imageLabel in imageLabels:
                image = ImageInfo()
                if imageLabel in item:
                    image.url = getattr(item, imageLabel).URL.text
                    image.width = int(getattr(item, imageLabel).Width.text)
                    image.height = int(getattr(item, imageLabel).Height.text)
                bookInfo.images[imageLabel] = image

            bookInfos.append(bookInfo)

    return bookInfos


def getXmls():
    xmls = []
    for i in range(0, 1440+1, 10):
        path = 'xmls/{}.xml'.format(i)
        with open(path, 'r') as f:
            xml = f.read()
            xmls.append(xml)
    return xmls


def main():
    xmls = getXmls()
    start = time.time()
    bookInfos = parseXmls(xmls)
    end = time.time()
    print('xml数: {}'.format(len(xmls)))
    print('book数: {}'.format(len(bookInfos)))
    print('parse時間: {}秒'.format(end - start))


if __name__ == '__main__':
    main()

# -*- encoding: utf-8 -*-
require 'sinatra'
require 'json'
require "rexml/document"
require 'nokogiri'
require 'open-uri'
require 'date'
require 'time'

def news(datetime = "now")
	if datetime == "now"
		starttime, endtime= (Time.now-24*60*60).strftime("%Y%m%d"),Time.now.strftime("%Y%m%d")
	else
		starttime, endtime= Time.parse(datetime).strftime("%Y%m%d"), (Time.parse(datetime)+24*60*60).strftime("%Y%m%d")
	end
	url = "http://appli.ntv.co.jp/ntv_WebAPI/news/?key=YourKey&word=*&period_start=" + starttime + "&period_end=" + endtime
	xml_doc = Nokogiri::XML(open(url))
	output = ""
	xml_doc.xpath('news/article').each do |element|
		output += element.xpath('title').text+"\n"+element.xpath('url').text+"\n"
	end
	return output + 'powered by 日テレアプリ'
end

def fun
  t = Date.today
  y = t - 1
  url = "http://appli.ntv.co.jp/ntv_WebAPI/news/?key=#{ENV["YOUR_KEY"] || "YOUR_KEY"}&word=*&period_start=#{y.strftime('%Y%m%d')}&period_end=#{t.strftime('%Y%m%d')}"
  images(url).sample
end

def images(url)
	xml_doc = Nokogiri::XML(open(url))
  xml_doc.xpath('news/article').map do |element|
    path = element.xpath('thumbnail_url').text.strip
    path if path != ""
  end.compact
end

post '/newslingr' do
        #data = JSON.parse(request.body)
        data = JSON.load(request.body)
        if data["status"] == "ok" and data["events"]
                data["events"].each do |e, text=e["message"]["text"]|
                        if text.index("!datenews") != nil
                                return news(text.split(" ")[1])
			else
				return ""
                        end
                end
	else
		return ""
        end
end

get '/newslingr' do
	"newslingr!!"
end

# -*- encoding: utf-8 -*-

require 'sinatra'
require 'json'
require "rexml/document"
require 'nokogiri'
require 'open-uri'
require 'date'
def pastnews(datetime)
	today, tomorrow = Time.parse(datetime).strftime("%Y%m%d"), (Time.parse(datetime)+24*60*60).strftime("%Y%m%d")
	url="http://appli.ntv.co.jp/ntv_WebAPI/news/?key=YourKey&word=*&period_start="+today+"&period_end="+tomorrow
	xml_doc = Nokogiri::XML(open(url))
	output=""
	xml_doc.xpath('news/article').each do |element|
		output += element.xpath('title').text+"\n"+element.xpath('url').text
	end
	return output+'\n'+'powered by 日テレアプリ'
end

def todaynews
	datetime=DateTime.now.strftime('%F')
	datetime_year=datetime.split('-')[0]
	datetime_month=datetime.split('-')[1]
	datetime_day=datetime.split('-')[2]
	datetimestart=datetime_year+datetime_month+datetime_day
	datetimestop=datetime_year+datetime_month+(datetime_day.to_i+1).to_s
	url="http://appli.ntv.co.jp/ntv_WebAPI/news/?key=YourKey&word=*&period_start="+datetimestart+"&period_end="+datetimestop
	xml_doc = Nokogiri::XML(open(url))
	output=""
	xml_doc.xpath('news/article').each do |element|
		output += element.xpath('title').text+"\n\r"+element.xpath('url').text
	end
	return output+'\n'+'http://www.ntv.co.jp/appli/api/howto/img/credit_api.gif'
end

post '/newslingr' do
        #data = JSON.parse(request.body)
        data = JSON.load(request.body)
        if data["status"] == "ok" and data["events"]
                data["events"].each do |e, text=e["message"]["text"]|
                        if text.index("!datenews") != nil
                                return pastnews(text.split(" ")[1])
                                #if(text.split(" ")[1].include?("-")==true) then
                                #        return pastnews(text.split(" ")[1])
                                #        #return 'http://v157-7-153-173.z1d1.static.cnode.jp/tmpfigure/TodenGraphDayLingr/PowerUsageGraph'+dateyear.to_s+'-'+datemon.to_s+'-'+dateday.to_s+'.png'
                                #else
                                #        return todaynews
                                #end
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

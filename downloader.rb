#!/usr/bin/ruby
require 'rubygems'
require 'open-uri' # for url parsing
require 'optparse' # for command line aoption parsing
require 'net/http' # to get page source
require 'json' # for parsing source for pics

$subreddits = ['earthporn', 'waterporn','nature','wallpaper','aww'] # sub-reddits to download from
$dir = './Wallpapers'

class DLoader
	def getOpts 
		options = {
		  :output_dir => $dir,
		  :reddits => $subreddits
		}

		optparse = OptionParser.new do|opts|
			opts.on('-d DIR', String, 'Local download directory') do |dir|
		    	options[:output_dir] = dir
		    end
		    opts.on('-r a,b,c,d,...', String, 'Subreddits to download from (comma separated)') do |subs|
		    	options[:reddits] = subs.split(',')
		    end
			opts.on( '-h', 'Display this screen' ) do
		    	puts opts
		    	exit
		    end
		end

		optparse.parse!

		p optparse
#		p options[:reddits]
#		p options[:output_dir]

		# append requested subs to default subs
		options[:reddits].each do |newsub|
			$subreddits.push(newsub.downcase)
		end
		p $subreddits
	
		# create output dir
		$dir = options[:output_dir]
		if(!Dir::exists?($dir))
			Dir::mkdir($dir)
		end
		Dir::chdir($dir)
		p $dir
	end

	def getUrls
		# generate custom url in the form "http://www.reddit.com/r/sub1+sub2+sub3+...+subn.com"
		url = 'http://www.reddit.com/r/'
		$subreddits.each do |subname|
			url = url + subname + '+'
		end
		url = url[0..-2] + '/hot.json?limit=20'
		p url

		# get source of new url
		source = getSource(url)
		# parse source for pictures
		urls = {}
		doc = JSON.parse(source.body)
		doc['data']['children'].each do |link|
		  urls[link['data']['title']] = link['data']['url']
		end

		urls.reject! do |name, url|
			is_picture?(url)
		end
		p urls

#		url = 'http://farm1.static.flickr.com/92/218926700_ecedc5fef7_o.jpg'
#		open(url){ |f|
#			File.open('newimage.jpg','wb') do |file|
#				file.puts f.read
#			end
#		}
	end
	def getSource(url)
			url_parsed = URI.parse(url)
	  		req = Net::HTTP::Get.new(url_parsed.path)
			
			Net::HTTP.start(url_parsed.host, url_parsed.port) do |http|
	    	http.request(req)
	  		end
	end 
	def is_picture?(file)
		valid = true
		valid = false if file =~ /^.+\.(?i)((bmp)|(gif)|(jpeg)|(jpg)|(png)|(tiff))$/
		valid = true  if file =~ /^.+\.(?i)(php)/
		valid
	end	

end

dl = DLoader.new
dl.getOpts
dl.getUrls

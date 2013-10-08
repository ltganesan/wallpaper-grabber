#!/usr/bin/ruby
require 'rubygems'
require 'open-uri' # for url parsing
require 'optparse' # for command line aoption parsing
require 'net/http' # to get page source
require 'net/https' # to get page source

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
		url = url[0..-2] + '/hot.json?limit=40' #default to "hot" and 30 posts
#		p url

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
		
		i = 0
		urls.each_pair do |name, url|
			puts name
			puts url
			# fix ssl error
			if url[0..4].eql?('https')
				url = 'http' + url[5..-1]
			end
			open(url){ |f|
				i = i + 1
				File.open("wp#{i}.jpg",'wb') do |file|
					file.puts f.read
				end
			}
		end
	end
	def getSource(url)
			url_parsed = URI.parse(url)
	  		req = Net::HTTP::Get.new(url_parsed.path)
			http = Net::HTTP.new(url_parsed.host, url_parsed.port)
			http.use_ssl = true if url_parsed.scheme == 'https'
			http.start do |h|
	    		h.request(req)
	  		end

	end 
	def is_picture?(file)
		valid = true
		valid = false if file =~ /^.+\.(?i)((bmp)|(jpeg)|(jpg)|(png)|(tiff))$/
		valid = true  if file =~ /^.+\.(?i)(php)/
		valid
	end	

	# Follow redirects
	def fetch(uri_str, limit = 10)
 		raise ArgumentError, 'HTTP redirect too deep' if limit == 0
 		response = Net::HTTP.get_response(URI.parse(uri_str))
		case response
 		when Net::HTTPSuccess     then response
		when Net::HTTPRedirection then fetch(response['location'], limit - 1)
			else
				response.error!
 	end
end
end

dl = DLoader.new
dl.getOpts
dl.getUrls

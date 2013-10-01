require 'open-uri' # for url parsing
require 'optparse' # for command line aoption parsing


# sub-reddits to download from
sub-reddits = ['EarthPorn', 'WaterPorn','nature','wallpaper']
dir = 'Wallpapers'

options = {
  :output_dir => dir,
  :reddits => reddits
}

optparse = OptionParser.new do|opts|
	opts.on('-d', '--dir DIR', String, 'Download directory') do |dir|
    	options[:output_dir] = dir
    end
    opts.on('r', '--r a,b,c,d', String, 'Subreddits comma separated') do |subs|
    	options[:reddits] = subs
    end
	opts.on( '-h', '--help', 'Display this screen' ) do
    	puts opts
    	exit
    end
end

optparse.parse!




def download_images(url)
	open(url){|f|
		File.open("file.jpg","wb") do |file|
    	file.puts f.read
   		end
   	}
   	return true
end


require "open-uri"


def download_images(url)
	open(url){|f|
		File.open("file.jpg","wb") do |file|
    	file.puts f.read
   		end
   	}
end
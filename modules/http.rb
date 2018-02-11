require 'open-uri'

class HttpDownloader {

def download(url):
    File.open('/target/path/to/downloaded.file', "wb") do |file|
        file.write open(url).read
    end
end

def download_basic_auth(url):
    File.open('/target/path/to/downloaded.file', "wb") do |file|
        file.write open(url, :http_basic_authentication => [your_username, your_password]).read
    end
end
}

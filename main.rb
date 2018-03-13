require_relative 'modules/http_downloader'
require_relative 'modules/download_list'
require_relative 'modules/http_session_manager'

def main()
  dl = HTTPDownloader.new()
  dlThread = dl.download_http('http://localhost/hosts.txt', '/tmp/hosts1.txt')
  #dlThread = dl.download_http('http://localhost/hosts.txt', '/tmp/hosts1.txt')
  #dl.download_http_basic_auth('http://localhost/hosts.txt', '/tmp/hosts2.txt', 'root', 'abc')

  list = DownloadList.new()
  list.add('http://localhost/hosts.txt')
end

main
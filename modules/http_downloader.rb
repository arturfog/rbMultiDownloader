#!/usr/bin/env ruby
require 'net/http'
require 'fileutils'
require 'thread'


class HTTPDownloader
  MAX_REDIRECTS = 10
  MAX_PARTS = 4
  def initialize
    @link = nil
    @total_bytes = 0
    @downloaded_bytes = 0
    @redirects_limit = 10
    @mutex = Mutex.new
    @file_path = ''
    @threads = []
    @do_download = true
  end

  attr_accessor :link
  attr_reader :redirects_limit
  attr_accessor :total_bytes
  # --------------------------------------------------------
  def do_download=(continue_dl)
    @mutex.synchronize {
      @do_download = continue_dl
    }
  end
  # --------------------------------------------------------
  def parts=(parts)
    @parts = parts > MAX_PARTS || parts < 0 ? 1 : parts
  end
  # --------------------------------------------------------
  def redirects_limit=(limit)
    @redirects_limit = limit > MAX_REDIRECTS || limit < 0 ? MAX_REDIRECTS : limit
  end
  # --------------------------------------------------------
  def downloaded_bytes=(bytes)
    @mutex.synchronize do
      @downloaded_bytes = bytes
    end
  end
  # --------------------------------------------------------
  def clean
    @link = nil
    @file_path = ''
  end
  # --------------------------------------------------------
  def isHttpLink?(address)
    address =~URI::regexp(%w(http https))
  end
  # --------------------------------------------------------
  # downloads file from http server to selected location
  # has support for 30x redirects
  def download_http(link, file_path)
    if !isHttpLink?(link.address) || file_path.to_s.empty?
      raise ArgumentError, 'URL and file path cannot be empty'
    end
    clean
    @link = link
    @file_path = file_path.to_s
    puts "Downloading [#{link.address}] to #{file_path}"
    handle_redirect(@link.address, @redirects_limit)
  end
  # --------------------------------------------------------
  def redirect_success(url, response)
    # success, we got correct address of resource
    self.total_bytes = response['content_length'].to_i
    @link.address = url

    if self.total_bytes < 65536
      @link.chunks = 1
    end

    puts "Starting thread for: #{url}"
    chunk_size_bytes = self.total_bytes / @link.chunks
    start_byte = 0
    end_byte = 0

    #for i in 1..@link.chunks
    #  @threads[i] = Thread.new { dl() }
    #  @threads[i].join
    #end
  end
  # --------------------------------------------------------
  def redirect_next(limit, response)
    location = response['location']
    warn "redirected to #{location}"
    handle_redirect(location, limit - 1)
  end
  # --------------------------------------------------------
  def redirect_fail
    warn "#{response.code} - #{response.message}"
    response.code
  end
  # --------------------------------------------------------
  def handle_redirect(url, limit)
    raise ArgumentError, 'too many HTTP redirects' if limit.zero?
    response = Net::HTTP.get_response(URI(url))
    case response
    when Net::HTTPSuccess then
      redirect_success url, response
    when Net::HTTPRedirection then
      redirect_next limit, response
    else
      redirect_fail
    end
  end
  # --------------------------------------------------------
  private def dl
    self.downloaded_bytes = 0
    uri = URI(@link.address)
    tmp_file_path = "#{@file_path}.tmp"

    warn "downlading #{@link.address} to #{tmp_file_path}"
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new(uri)
      request['Range'] = 'bytes=64-1024'
      request.basic_auth @link.user, @link.pass unless @link.user.empty?

      http.request request do |response|
        open tmp_file_path, 'w' do |io|
          response.read_body do |chunk|
            self.downloaded_bytes = chunk.size
            io.write chunk
          end
        end
      end
      FileUtils.move(tmp_file_path, @file_path) if File.exist?(tmp_file_path)
    end
  end
  # --------------------------------------------------------
  # Downloads file from websites that require basic auth
  def download_http_basic_auth(link)
    clean_first

    @link = link
    @file_path = file_path

    dl
  end
  # --------------------------------------------------------
  def progress
    @mutex.synchronize do
      [@downloaded_bytes, @total_bytes]
    end
  end
end

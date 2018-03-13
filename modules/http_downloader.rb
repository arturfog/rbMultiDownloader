#!/usr/bin/env ruby
require 'net/http'
require 'fileutils'
require 'thread'


class HTTPDownloader
  MAX_REDIRECTS = 10
  MAX_PARTS = 4
  def initialize
    @total_bytes = 0
    @downloaded_bytes = 0
    @redirects_limit = 10
    @parts = 1
    @mutex = Mutex.new
    @user = ''
    @pass = ''
    @url = ''
    @file_path = ''
    @threads = []
    @do_download = true
  end

  attr_accessor :user
  attr_accessor :pass
  attr_reader :redirects_limit
  attr_accessor :parts
  attr_accessor :total_bytes

  def do_download=(continue_dl)
    @mutex.synchronize {
      @do_download = continue_dl
    }
  end

  def parts=(parts)
    @parts = parts > MAX_PARTS || parts < 0 ? 1 : parts
  end

  def redirects_limit=(limit)
    @redirects_limit = limit > MAX_REDIRECTS || limit < 0 ? MAX_REDIRECTS : limit
  end

  def downloaded_bytes=(bytes)
    @mutex.synchronize do
      @downloaded_bytes = bytes
    end
  end

  def clean_first
    self.user = ''
    self.pass = ''
    @url = ''
    @file_path = ''
  end

  # downloads file from http server to selected location
  # has support for 30x redirects
  def download_http(url, file_path)
    if url.to_s.empty? || file_path.to_s.empty?
      raise ArgumentError, 'URL and file path cannot be empty'
    end
    clean_first

    @url = url.to_s
    @file_path = file_path.to_s

    handle_redirect(@url, @redirects_limit)
  end

  def redirect_success(url, response)
    # success, we got correct address of resource
    self.total_bytes = response['content_length'].to_i
    @url = url.to_s
    @threads[0] = Thread.new { dl() }
    @threads[0].join
  end

  def redirect_next(limit, response)
    location = response['location']
    warn "redirected to #{location}"
    handle_redirect(location, limit - 1)
  end

  def redirect_fail
    warn "#{response.code} - #{response.message}"
    response.code
  end

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

  private def dl
    self.downloaded_bytes = 0
    uri = URI(@url)
    tmp_file_path = "#{@file_path}.tmp"

    warn "downlading #{@url} to #{tmp_file_path}"
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new(uri)
      request.basic_auth @user, @pass unless @user.empty?

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

  # Downloads file from websites that require basic auth
  def download_http_basic_auth(url, file_path, user, pass)
    clean_first

    self.user = user
    self.pass = pass

    @url = url
    @file_path = file_path

    dl
  end

  def progress
    @mutex.synchronize do
      [@downloaded_bytes, @total_bytes]
    end
  end
end

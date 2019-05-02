#!/usr/bin/env ruby
require 'net/http'
require 'fileutils'
require 'thread'

class FTPDownloader
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
    def downloading?
        @mutex.synchronize {
            @do_download
        }
    end
end
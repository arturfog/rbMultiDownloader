#!/usr/bin/env ruby
require_relative 'modules/http_downloader'
require_relative 'modules/download_list'
require_relative 'modules/http_session_manager'

require 'ostruct'
require 'optparse'
require 'pp'

class Optparse
  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.url = ''
    options.txt = ''
    options.parts = 1
    options.verbose = false
    options.filename = ''
    options.outDir = Dir.pwd
    options.user = ''
    options.pass = ''

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: main.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"
      # --------------------------------------------------------
      opts.on("-a", "--url URL",
              "URL to download") do |url|
        options.url = url
      end
      # --------------------------------------------------------
      opts.on("-p", "--parts N", OptionParser::DecimalInteger,
              "How many connections to use during download") do |parts|
        options.parts = parts
      end
      # --------------------------------------------------------
      opts.on("-l", "--list PATH", "Path to file with url list") do |txt|
        options.txt = txt
      end
      # --------------------------------------------------------
      opts.on("-O", "--out PATH", "Filename of file to be downloaded") do |filename|
        options.filename = filename
      end
      # --------------------------------------------------------
      opts.on("-d", "--dir PATH", "Dir where files will be downloaded") do |outDir|
        options.outDir = outDir
      end
      # --------------------------------------------------------
      opts.on("-u", "--user USER", "Username to be used when dowloading") do |user|
        options.user = user
      end
      # --------------------------------------------------------
      opts.on("-p", "--pass PASS", "Password to be used when dowloading") do |pass|
        options.pass = pass
      end
      # --------------------------------------------------------
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end
      # --------------------------------------------------------
      opts.separator ""
      opts.separator "Common options:"
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
      # --------------------------------------------------------
      opts.on_tail("--version", "Show version") do
        puts "0.1a"
        exit
      end
    end

    opt_parser.parse!(args)
    # return
    options
  end # parse()
end # class Optparse
# --------------------------------------------------------
def gen_progressbar(filename ,downloaded, total)
  dl_kb = downloaded.to_i / 1024
  total_kb = total.to_i / 1024
  precentage = dl_kb.to_f / total_kb * 100;

  print "#{filename}: ["

  for i in 1..20
    if (precentage.to_i / 10) >= (i / 2)
      print "#"
    else
      print "-"
    end

  end
  print "] #{precentage.to_i}% [#{dl_kb} kB / #{total_kb} kB]"
end

def parse_eta(eta_sec)
  hours = eta_sec / 3600
  minutes = (eta_sec % 3600) / 60
  seconds = (eta_sec % 60)

  [hours, minutes, seconds]
end
# --------------------------------------------------------
def get_download_speed_eta(dl, total, duration_sec)
  dl_speed = 65536
  eta_sec = (total - dl) / dl_speed
  eta = parse_eta(eta_sec)
  print " (kB/S: #{dl_speed} ETA: #{eta[0]}:#{eta[1]}:#{eta[2]}) \r"
  [dl_speed, eta]
end
# --------------------------------------------------------
def get_download_progress(dl)
  while dl.downloading?
    p = dl.progress()
    filename = dl.get_link.filename
    gen_progressbar(filename, p[0], p[1])
    get_download_speed_eta(p[0], p[1], 1)
    sleep(0.1)
  end
  puts ""
end
# --------------------------------------------------------
def show_progress(dl)
  @thread = Thread.new { get_download_progress(dl) }
  @thread.join
end
# --------------------------------------------------------
def main()
  options = Optparse.parse(ARGV)
  pp options

  dl = HTTPDownloader.new()
  list = DownloadList.new()
  if options.url.empty? == false
    list.add(options.url.strip, options.parts, options.filename, options.outDir)
  end

  if options.txt.empty? == false
    list.add_from_file(options.txt.strip, options.outDir)
  end

  for link in list.getDlList()
    dl.download_http(link)
    get_download_progress(dl)
  end
end
# --------------------------------------------------------
main
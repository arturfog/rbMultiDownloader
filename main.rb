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
    options.path = ''
    options.outDir = '/tmp/'
    options.user = ''
    options.pass = ''

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"
      # --------------------------------------------------------
      opts.on("-u", "--url URL",
              "URL to download") do |url|
        options.url = url
      end
      # --------------------------------------------------------
      opts.on("-p", "--parts N", OptionParser::DecimalInteger,
              "How many connections to use during download") do |parts|
        options.parts = parts
      end
      # --------------------------------------------------------
      opts.on("-t", "--txt PATH", "Path to file with url list") do |txt|
        options.txt = txt
      end
      # --------------------------------------------------------
      opts.on("-O", "--outPath PATH", "Path where file will be downloaded") do |path|
        options.path = path
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
        puts ::Version.join('.')
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end # parse()
end # class Optparse

def main()
  options = Optparse.parse(ARGV)
  pp options

  dl = HTTPDownloader.new()
  list = DownloadList.new()
  if options.url != ''
    list.add(options.url, options.parts)
  end

  if options.txt != ''
    list.add_from_file(options.txt)
  end

  for link in list.getDlList()
    dlThread = dl.download_http(link, options.outDir + '/hosts1.txt')
  end
end

main
require 'uri'

class DownloadList
  def initialize
    @dlList = []
  end
  def create_dl_item(address, chunks, user, pass, filename, outDir)
    link = OpenStruct.new
    link.address = address
    link.chunks = chunks
    link.user = user
    link.pass = pass
    link.filename = filename
    link.outDir = outDir

    link
  end
  # --------------------------------------------------------
  def isHttpLink?(address)
    address =~URI::regexp(%w(http https))
  end
  # --------------------------------------------------------
  def isFtpLink?(address)
    address =~URI::regexp(%w(ftp))
  end
  # --------------------------------------------------------
  def getDlList()
    @dlList
  end
  # --------------------------------------------------------
  def add(address, chunks = 1, filename='', outDir='', user='', pass='')
    if isHttpLink?(address)
      puts "Valid link: #{address}"

      if filename and filename.empty?
        uri = URI.parse(address)
        filename = uri.path
      end

      if outDir.empty?
        outDir = Dir.pwd
      end

      link = create_dl_item(address, chunks, user, pass, filename, outDir)
      @dlList.append(link)
    end
  end
  # --------------------------------------------------------
  def add_from_file(file_path, outDir)
    unless file_path.empty?
      File.foreach(file_path).with_index do |line, line_num|
        puts "#{line_num}: #{line}"
        add(line.strip, 1, '', outDir)
      end
    end
  end
end
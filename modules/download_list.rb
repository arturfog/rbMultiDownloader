require 'uri'

class DownloadList
  def initialize
    @dlList = []
  end
  def create_dl_item(address, chunks, user, pass)
    link = OpenStruct.new
    link.address = address
    link.chunks = chunks
    link.user = user
    link.pass = pass

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
  def add(address, chunks = 1, user='', pass='')
    if isHttpLink?(address)
      puts "Valid link: #{address}"
      link = create_dl_item(address, chunks, user, pass)
      @dlList.append(link)
    end
  end
  # --------------------------------------------------------
  def add_from_file(file_path)
    unless file_path.empty?
      File.foreach(file_path).with_index do |line, line_num|
        puts "#{line_num}: #{line}"
        add(line.strip, 1, '','')
      end
    end
  end
end
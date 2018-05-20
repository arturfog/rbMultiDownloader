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
      link = create_dl_item(address, chunks, user, pass)
      @dlList.append(link)
    end
  end
  # --------------------------------------------------------
  def add_from_file(file_path)

  end
end
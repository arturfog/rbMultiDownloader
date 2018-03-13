class DownloadList
  def initialize
    @httpList = []
    @ftpList = []

  end

  def isHttpLink?(address)
    false
  end

  def isFtpLink(address)
    false
  end

  def add(address, chunks = 1, user='', pass='')
    if isHttpLink?(address)
      addHttp(address, chunks)
    elsif isFtpLink(address)
      addFtp(address, chunks)
    end
  end

  private def addHttp(url, chunks)
    @httpList.append(url)
  end

  private def addFtp(url, chunks)
    @ftpList.append(url)
  end
end
class HttpSessionManager
  def initialize
    @urls_configs = []
  end
  # logins to website and returns Cookie
  def getCookie()
    pass
  end

  def get_website_mapping(file)
    @urls_configs['www.catshare.net'] = 'catshare.xml'
  end
  # searches dir for XML files with login configurations
  def load_available_configs(dir)
    unless Dir.exist?(dir)
      with Dir.entries do |file|
        get_website_mapping(file)
      end
    end
  end

  # loads login configuration for selected website ie. dropbox
  def load_config_for_url(base_url)
    file_path = @urls_configs[base_url].to_s
    unless file_path.empty?
      open(file_path) do |io|
        printf 'Test'
      end
    end
  end
end
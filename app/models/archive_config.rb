class ArchiveConfig < ApplicationRecord
  def self.site_config
    @@site_config ||= find_by_key(APP_CONFIG[:sitekey])
  end
end

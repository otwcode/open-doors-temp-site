class ArchiveConfig < ApplicationRecord
  def self.archive_config
    find_by_key(APP_CONFIG[:sitekey])
  end
end

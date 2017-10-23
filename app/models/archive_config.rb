class ArchiveConfig < ApplicationRecord
  validates_presence_of :name, :host
  
  def self.archive_config
    find_by_key(APP_CONFIG[:sitekey])
  end
end

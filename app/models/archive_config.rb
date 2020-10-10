class ArchiveConfig < ApplicationRecord
  validates_presence_of :name, :host
  
  def self.archive_config
    find_by_key(ENV['SITEKEY'])
  end
  
  def to_hash
    as_json
  end
end

class ArchiveConfig < ApplicationRecord
  validates_presence_of :name, :host
  
  def self.archive_config
    find_by_key(ENV['RAILS_RELATIVE_URL_ROOT'])
  end
  
  def to_hash
    as_json
  end
end

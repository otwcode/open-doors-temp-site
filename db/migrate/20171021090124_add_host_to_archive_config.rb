class AddHostToArchiveConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :archive_configs, :host, :string
  end
end

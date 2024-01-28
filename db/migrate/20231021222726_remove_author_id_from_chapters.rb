class RemoveAuthorIdFromChapters < ActiveRecord::Migration[5.2]
  def change
    if ActiveRecord::Base.connection.column_exists?(:chapters, :authorID)
      remove_column :chapters, :authorID
    end
  end
end

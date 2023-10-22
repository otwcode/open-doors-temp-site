class RemoveAuthorIdFromChapters < ActiveRecord::Migration[5.2]
  def change
    remove_column :chapters, :authorID, :integer
  end
end

class ChangeIdOnUsers < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE users ALTER COLUMN id SET DATA TYPE bigint;"
    execute "ALTER TABLE events ALTER COLUMN user_id SET DATA TYPE bigint;"
  end

  def down
    change_column :users, :id, :integer
    change_column :events, :user_id, :string
  end
end

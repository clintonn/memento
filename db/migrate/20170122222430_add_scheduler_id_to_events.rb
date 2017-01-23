class AddSchedulerIdToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :scheduler_id, :string
  end
end

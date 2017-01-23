class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string :message
      t.datetime :event_date
      t.string :event_reminder_time
      t.timestamps
    end
  end
end

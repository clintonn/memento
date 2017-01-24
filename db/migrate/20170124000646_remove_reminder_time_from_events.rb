class RemoveReminderTimeFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :event_reminder_time
  end
end

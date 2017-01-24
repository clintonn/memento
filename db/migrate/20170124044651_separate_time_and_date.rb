class SeparateTimeAndDate < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :date, :datetime
    add_column :events, :time, :string
  end
end

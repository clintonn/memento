class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.decimal :timezone, precision: 2, scale: 1
      t.timestamps
    end
  end
end

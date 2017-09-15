class CreateMeters < ActiveRecord::Migration[5.1]
  def change
    create_table :meters do |t|
      t.references :apartment, foreign_key: true
      t.integer :meter_type
      t.date :date
      t.integer :quantity

      t.timestamps
    end
  end
end

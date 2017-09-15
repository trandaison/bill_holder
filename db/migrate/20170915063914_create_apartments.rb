class CreateApartments < ActiveRecord::Migration[5.1]
  def change
    create_table :apartments do |t|
      t.string :pic
      t.string :email

      t.timestamps
    end
  end
end

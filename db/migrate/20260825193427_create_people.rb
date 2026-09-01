class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :people do |t|
      t.string :name
      t.string :rut
      t.integer :age
      t.string :address

      t.timestamps
    end
  end
end

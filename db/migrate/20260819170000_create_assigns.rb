class CreateAssigns < ActiveRecord::Migration[8.1]
  def change
    create_table :assigns do |t|
      t.string :titulo
      t.date :fecha_inscripcion

      t.timestamps
    end
  end
end

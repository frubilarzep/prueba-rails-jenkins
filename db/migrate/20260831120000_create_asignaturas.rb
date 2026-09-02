class CreateAsignaturas < ActiveRecord::Migration[8.1]
  def change
    create_table :asignaturas do |t|
      t.string :nombre
      t.string :codigo
      t.integer :seccion
      t.string :semestre

      t.timestamps
    end
  end
end

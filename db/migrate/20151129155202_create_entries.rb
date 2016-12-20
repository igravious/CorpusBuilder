class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :dictionary_id
      t.string :label
      t.text :body

      t.timestamps
    end
  end
end

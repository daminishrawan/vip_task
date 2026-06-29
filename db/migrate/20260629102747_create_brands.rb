class CreateBrands < ActiveRecord::Migration[8.1]
  def change
    create_table :brands do |t|
      t.string :name, null: false
      t.string :country_of_origin, null: false
      t.string :category, null: false

      t.timestamps
    end
    add_index :brands, :name, unique: true
  end
end

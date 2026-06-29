class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.integer :price_cents
      t.decimal :alcohol_by_volume
      t.integer :stock_quantity
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end

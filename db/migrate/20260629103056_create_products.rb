class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.integer :price_cents, null: false
      t.decimal :alcohol_by_volume, precision: 4, scale: 2, default: 0.0
      t.integer :stock_quantity, default: 0, null: false
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
    add_index :products, :sku, unique: true
  end
end

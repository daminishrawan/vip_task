class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :status, null: false, default: "pending"
      t.integer :total_cents, null: false, default: 0
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end

class AddProductsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :dishes do |t|
      t.string :name
      t.string :ingredient, index: true
      t.string :spice, index: true

      t.timestamps
    end
  end
end

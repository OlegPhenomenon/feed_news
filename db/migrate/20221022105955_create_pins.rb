class CreatePins < ActiveRecord::Migration[7.0]
  def change
    create_table :pins do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.integer :position, null: false, unique: true

      t.timestamps
    end
  end
end

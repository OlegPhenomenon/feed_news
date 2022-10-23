class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.integer :status, null: false, default: 0
      t.timestamp :published_at, null: true
      t.string :title, null: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

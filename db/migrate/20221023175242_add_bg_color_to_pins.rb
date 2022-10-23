class AddBgColorToPins < ActiveRecord::Migration[7.0]
  def change
    add_column :pins, :bg_color, :string, null: false
  end
end

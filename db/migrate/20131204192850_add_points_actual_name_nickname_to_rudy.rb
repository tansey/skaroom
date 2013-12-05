class AddPointsActualNameNicknameToRudy < ActiveRecord::Migration
  def change
    add_column :rudies, :points, :integer, default: 0
    add_column :rudies, :actual_name, :string
    add_column :rudies, :nickname, :string
  end
end

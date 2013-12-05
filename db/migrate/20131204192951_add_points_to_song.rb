class AddPointsToSong < ActiveRecord::Migration
  def change
    add_column :songs, :points, :integer, default: 0
  end
end

class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :artist
      t.string :title
      t.float :duration
      t.string :song
      t.references :rudy

      t.timestamps
    end
  end
end

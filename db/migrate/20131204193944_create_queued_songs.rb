class CreateQueuedSongs < ActiveRecord::Migration
  def change
    create_table :queued_songs do |t|
      t.references :rudy, index: true
      t.references :song, index: true
      t.integer :sequence

      t.timestamps
    end
  end
end

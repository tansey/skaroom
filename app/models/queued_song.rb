class QueuedSong < ActiveRecord::Base
  belongs_to :rudy
  belongs_to :song
end

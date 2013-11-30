class Song < ActiveRecord::Base
  mount_uploader :song, MusicUploader
  belongs_to :rudy
end

class Song < ActiveRecord::Base
  mount_uploader :song, MusicUploader
end

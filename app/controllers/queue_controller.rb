class QueueController < ApplicationController
  def upload
    if params[ :upload_music ].content_type == 'audio/mp3'
      require 'mp3info'
      info = Mp3Info.open params[ :upload_music ].tempfile
      artist    = info.tag.artist
      title     = info.tag.title
      duration  = info.length.round
      song = Song.where( artist: artist, title: title, duration: duration ).first
      if song.nil? and not song.artist.nil? and not song.title.nil? and not song.duration.nil?
        song = Song.new
        song.song = params[ :upload_music ]
        song.artist   = artist
        song.title    = title
        song.duration = duration
        song.rudy     = current_rudy
        song.save

        render json: { files: [ { id: song.id, title: song.title, artist: song.artist, song: song.song.to_s } ] }
      else
        render json: { files: [] }
      end
    else
      render json: { files: [] }
    end
  end
end

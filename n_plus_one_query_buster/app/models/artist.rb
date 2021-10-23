class Artist < ApplicationRecord
  has_many :albums,
    class_name: 'Album',
    foreign_key: :artist_id,
    primary_key: :id

  def n_plus_one_tracks
    albums = self.albums
    tracks_count = {}
    albums.each do |album|
      tracks_count[album.title] = album.tracks.length
    end

    tracks_count
  end

  def better_tracks_query
    albums_with_num_tracks = self.albums.joins(:tracks).group(:id).select("albums.*, COUNT(*) AS num_tracks")

    albums_with_num_tracks.map do |album|
      [album.title, album.num_tracks]
    end

  end
end

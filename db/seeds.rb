# frozen_string_literal:true

Artist.destroy_all

artists = ['Red hot chilly peppers', 'The rolling Stones', 'The beatles']

artists.each do |artist|
  new_artist = Artist.new(name: artist)
  new_artist.save
end

# frozen_string_literal:true

require('open-uri')
require('nokogiri')

User.destroy_all
Artist.destroy_all
Song.destroy_all

gregoire = User.create!(email: 'gregoire.vallette@gmail.com', password: 'gregreg')
gregoire.save!

# find first result URL from search string
def find_url(search)
  search_url = "https://www.musixmatch.com/fr/search/#{search}/tracks"
  search_page = Nokogiri::HTML(URI.open(search_url.gsub(' ', '%20')).read)

  song_link = search_page.search('.title').first['href']
  "https://www.musixmatch.com/#{song_link}"
rescue StandardError => e
  p "Something went wrong with search #{search}"
  p e
end

# find lyrics from search first result URL
def find_lyrics(song_url)
  song_page = Nokogiri::HTML(URI.open(song_url).read)
  song_page.search('.mxm-lyrics__content').to_a.join("\n")
rescue StandardError => e
  p "problem finding lyrics @ #{song_url}"
  p e
end

# find title from search first result URL
def find_title(song_url)
  song_page = Nokogiri::HTML(URI.open(song_url).read)
  song_page.search('.mxm-track-title__track').first.text.gsub('Paroles', '')
rescue StandardError => e
  p "problem finding title @ #{song_url}"
  p e
end

# search only by artist
def search_artist(search)
  search_url = "https://www.musixmatch.com/fr/search/#{search}/artists"
  search_page = Nokogiri::HTML(URI.open(search_url.gsub(' ', '%20')).read)
  search_page.search('.cover').first.children[0].text
rescue StandardError => e
  p "something went wrong with searching artist: #{search}"
  p e
end

ARTISTS = ['Red hot chili peppers', 'The Rolling Stones', 'The Beatles'].freeze

SONGS = [['By the Way', 'snow Hey Oh', 'Under The Bridge'],
         ['wild horses', 'Paint It Black', "Jumpin' Jack Flash"],
         ['Because', 'Come Together', 'Here Comes The Sun']].freeze

ARTISTS.each_with_index do |artist, index|
  new_artist = Artist.new(name: search_artist(artist))
  if new_artist.save!
    SONGS[index].each do |song|
      search_string = "#{artist} #{song}"
      url = find_url(search_string)
      new_song = Song.new(user: User.last)
      new_song.artist = Artist.last
      new_song.title = find_title(url)
      new_song.lyrics = find_lyrics(url)
      new_song.save!
      p "successfully saved song: #{song}"
    rescue StandardError => e
      p "something went wrong saving song: #{song}"
      p e
    end
  else
    p "something went wrong saving artist: #{artist}"
  end
end

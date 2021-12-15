# frozen_string_literal:true

# songs controller
class SongsController < ApplicationController
  require('open-uri')
  require('nokogiri')

  def index
    @songs = Song.includes(:artist).order('artists.name')
  end

  def show
    @song = Song.find(params[:id])
  end

  def new
    @song = Song.new
  end

  def create
    artist = search_artist(params[:song][:artist])
    url = find_url("#{params[:song][:artist]} #{params[:song][:title]}")
    title = find_title(url)
    lyrics = find_lyrics(url)
    song = Song.new(user: current_user)
    song.artist = artist
    song.title = title
    song.lyrics = lyrics
    song.save!
    redirect_to song_path(song)
  rescue StandardError => e
    p e
    flash.alert = 'Something went wrong with saving song, try some other search terms...'
    redirect_to new_song_path
  end

  def destroy
    song = Song.find(params[:id])
    song.destroy!
    flash.notice = 'Song deleted successfully'
    redirect_to songs_path
  end

  private

  # find first result URL from search string
  def find_url(search)
    search_url = "https://www.musixmatch.com/fr/search/#{search}/tracks"
    search_page = Nokogiri::HTML(URI.open(search_url.gsub(' ', '%20')).read)

    song_link = search_page.search(".title").first['href']
    "https://www.musixmatch.com/#{song_link}"
  rescue StandardError => e
    p "Something went wrong with search #{search}"
    p e
    nil
  end

  # find lyrics from search first result URL
  def find_lyrics(song_url)
    song_page = Nokogiri::HTML(URI.open(song_url).read)
    song_page.search('.mxm-lyrics__content').to_a.join("\n")
  rescue StandardError => e
    p "problem finding lyrics @ #{song_url}"
    p e
    nil
  end

  # find title from search first result URL
  def find_title(song_url)
    song_page = Nokogiri::HTML(URI.open(song_url).read)
    song_page.search('.mxm-track-title__track').first.text.gsub('Paroles', '')
  rescue StandardError => e
    p "problem finding title @ #{song_url}"
    p e
    nil
  end

  # search only by artist
  def search_artist(search)
    search_url = "https://www.musixmatch.com/fr/search/#{search}/artists"
    search_page = Nokogiri::HTML(URI.open(search_url.gsub(' ', '%20')).read)
    artist_name = search_page.search('.cover').first.children[0].text
    existing_artist = Artist.find_by(name: artist_name)
    if existing_artist
      existing_artist
    else
      new_artist = Artist.new(name: artist_name)
      new_artist.save!
      Artist.last
    end
  rescue StandardError => e
    p "something went wrong with searching artist: #{search}"
    p e
  end
end

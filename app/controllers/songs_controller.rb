# frozen_string_literal:true

# songs controller
class SongsController < ApplicationController
  def index
    @songs = Song.all.order(artist: :asc)
  end

  def show

  end

  def create

  end
end

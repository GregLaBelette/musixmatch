# frozen_string_literal:true

# songs controller
class SongsController < ApplicationController
  def index
    @songs = Song.includes(:artist).order(artist: :asc)
  end

  def show
    @song = Song.find(params[:id])
  end

  def new
    @song = Song.new
  end

  def create

  end
end

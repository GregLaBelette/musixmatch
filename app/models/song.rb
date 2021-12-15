# frozen_string_literal:true

class Song < ApplicationRecord
  belongs_to :artist
  belongs_to :user

  validates :title, presence: true
  validates :lyrics, presence: true
  validates :lyrics, length: { minimum: 10 }
end

# frozen_string_literal:true

class Artist < ApplicationRecord
  validates :name, presence: true
  validates :name, length: { minimum: 2 }

  has_many :songs, dependent: :destroy
end

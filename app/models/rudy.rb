class Rudy < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, uniqueness: { case_sensitive: false }

  #has_many :songs
  has_many :queued_songs
  has_many :songs, through: :queued_songs, order: :sequence
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :posts, dependent: :destroy
  has_many :pins, dependent: :destroy
  has_many :sorted_pins, -> { order(position: :asc) }, class_name: 'Pin'

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { minimum: 5, maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates_uniqueness_of :username, message: 'Somebody has the same username'
  validates :password, :password_confirmation, presence: true, on: :create

  def pins?
    pins.count != 0
  end
end

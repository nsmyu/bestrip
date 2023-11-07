class User < ApplicationRecord
  include Placeable

  has_many :itinerary_users, dependent: :destroy
  has_many :itineraries, through: :itinerary_users
  has_many :owned_itineraries, class_name: "Itinerary", dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :name,       presence: true, length: { maximum: 20 }
  VALID_BESTRIP_ID_REGEX = /\A[\w]{5,20}\z/
  validates :bestrip_id, uniqueness: { case_sensitive: false },
                         length: { minimum: 5, maximum: 20 },
                         format: { with: VALID_BESTRIP_ID_REGEX },
                         allow_blank: true
  validates :email,      presence: true, uniqueness: true
  VALID_PASSWORD_REGEX = /\A[a-z\d]{6,128}\z/i
  with_options unless: -> { validation_context == :without_password } do
    validates :password, presence: true, format: { with: VALID_PASSWORD_REGEX }
    validates :password_confirmation, presence: true
  end
  validates :introduction, length: { maximum: 500 }

  after_create :add_guest_to_itineraries, if: :guest?

  devise :database_authenticatable, :registerable, :rememberable, :validatable
  mount_uploader :avatar, AvatarUploader

  def self.guest
    random_pass = SecureRandom.base36
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.name = "ゲスト様"
      user.password = random_pass
      user.password_confirmation = random_pass
    end
  end

  def guest?
    email == 'guest@example.com'
  end

  private

  def add_guest_to_itineraries
    Itinerary.where(id: [1, 9, 12, 13, 15]).each { |itinerary| itinerary.members << self }
  end
end

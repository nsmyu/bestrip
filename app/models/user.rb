class User < ApplicationRecord
  has_many :itinerary_users
  has_many :itineraries, through: :itinerary_users
  has_many :owned_itineraries, class_name: "Itinerary", dependent: :destroy
  has_many :posts, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_user_email, if: :guest_user?, on: :create

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

  mount_uploader :avatar, AvatarUploader

  def self.guest
    random_pass = SecureRandom.base36
    create!(name: "ゲストユーザー", password: random_pass, password_confirmation: random_pass, guest: true)
  end

  def set_user_email
    while email.blank? || User.find_by(email: email)
      self.email = "guest_#{SecureRandom.base36}@example.com"
    end
  end

  def guest_user?
    guest
  end
end

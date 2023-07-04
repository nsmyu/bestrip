class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # has_many :rooms, dependent: :destroy
  # has_many :reservations, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  validates :name,         presence: true, length: { maximum: 50 }
  validates :bestrip_id,   uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :email,        presence: true, uniqueness: true, length: { maximum: 255 }
  validates :password,     presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :introduction, length: { maximum: 2000 }

  # def update_without_current_password(params)
  #   update(params)
  # end
end

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: 'User', optional: true
  has_many   :replies, class_name: 'User', foreign_key: :parent_id

  validates :content, presence: true, length: { maximum: 1000 }
end

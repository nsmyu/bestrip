class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many   :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy
  counter_culture :parent, column_name: "replies_count"

  validates :content, presence: true, length: { maximum: 1000 }
end

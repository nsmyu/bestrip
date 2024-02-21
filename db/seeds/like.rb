Post.all.each do |post|
  user_ids = User.pluck(:id).shuffle
  (5..10).to_a.sample.times do
    post.likes.new(user_id: user_ids.first).save
    user_ids.shift
  end
end

FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post_#{n}" }
    photos  { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec/fixtures/test_image.jpg'))}
    caption { "One of the best trips ever." }
    itinerary
    user { itinerary.owner }
  end
end

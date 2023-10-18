FactoryBot.define do
  factory :photo do
    url { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec/fixtures/cat.jpg')) }
    post
  end
end

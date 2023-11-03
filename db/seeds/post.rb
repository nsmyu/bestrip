Post.create!(
  [
    {
      title: Itinerary.find(1).title,
      caption: "シドニーに行ってきました！\n" +  "#オーストラリア #シドニー #海外旅行",
      itinerary_public: true,
      created_at: "2023-11-01",
      user: User.find(1),
      itinerary: Itinerary.find(1),
      photos_attributes: [
        {
          url: File.open("./app/assets/images/itinerary_post/disney.jpg"),
        },
        {
          url: File.open("./app/assets/images/itinerary_post/disney.jpg"),
        },
        {
          url: File.open("./app/assets/images/itinerary_post/disney.jpg"),
        }
      ]
    }
  ]
)

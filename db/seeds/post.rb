Post.create!(
  [
    {
      title: "シドニー 5泊6日",
      caption: "シドニーに行ってきました！\n #オーストラリア #シドニー #海外旅行",
      created_at: "2023-11-01",
      itinerary_public: true,
      user: User.find(1),
      itinerary: Itinerary.find(1),
    }
  ]
)

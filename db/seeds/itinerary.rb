Itinerary.create!(
  [
    {
      title: "シドニー満喫 4泊6日",
      image: File.open("./app/assets/images/itinerary_post/sydney.jpg"),
      departure_date: "2023-11-01",
      return_date: "2023-11-06",
      owner: User.find(1),
    },
    {
      title: "ディズニー&東京いろいろ",
      image: File.open("./app/assets/images/itinerary_post/disneysea.jpg"),
      departure_date: "2023-04-01",
      return_date: "2023-04-03",
      owner: User.find(1),
    },
    {
      title: "宮古島ダイビング旅行🐠",
      image: File.open("./app/assets/images/itinerary_post/miyako.jpg"),
      departure_date: "2022-07-01",
      return_date: "2022-07-03",
      owner: User.find(1),
    },
    {
      title: "北海道旅行⛄️",
      image: File.open("./app/assets/images/itinerary_post/otaru.jpg"),
      departure_date: "2022-12-01",
      return_date: "2022-12-04",
      owner: User.find(2),
    },
    {
      title: "スペイン🇪🇸 バルセロナ&グラナダ",
      departure_date: "2023-05-01",
      return_date: "2023-05-08",
      owner: User.find(2),
    },
    {
      title: "USJ&大阪観光",
      image: File.open("./app/assets/images/itinerary_post/usj.jpg"),
      departure_date: "2022-10-01",
      return_date: "2022-10-03",
      owner: User.find(2),
    },
    {
      title: "東京王道スポット巡り🗼",
      image: File.open("./app/assets/images/itinerary_post/asakusa.jpg"),
      departure_date: "2023-04-01",
      return_date: "2023-04-02",
      owner: User.find(3),
    },
    {
      title: "シンガポール3泊4日の旅",
      image: File.open("./app/assets/images/itinerary_post/merlion.jpg"),
      departure_date: "2023-08-01",
      return_date: "2023-08-04",
      owner: User.find(3),
    },
    {
      title: "トルコ🇹🇷カッパドキアいきたい",
      departure_date: "2024-03-01",
      return_date: "2024-03-07",
      owner: User.find(3),
    },
    {
      title: "ベトナム一人旅",
      departure_date: "2023-03-01",
      return_date: "2023-03-05",
      owner: User.find(4),
    },
    {
      title: "メルボルン一週間の旅",
      image: File.open("./app/assets/images/itinerary_post/melbourne.jpg"),
      departure_date: "2022-11-01",
      return_date: "2022-11-07",
      owner: User.find(4),
    },
    {
      title: "沖縄旅行🌺",
      image: File.open("./app/assets/images/itinerary_post/aquarium.jpg"),
      departure_date: "2023-07-01",
      return_date: "2023-07-04",
      owner: User.find(4),
    },
    {
      title: "タイ5日間の旅",
      image: File.open("./app/assets/images/itinerary_post/thailand.jpg"),
      departure_date: "2023-04-01",
      return_date: "2023-04-05",
      owner: User.find(5),
    },
    {
      title: "夏休み🌻北海道",
      image: File.open("./app/assets/images/itinerary_post/biei.jpg"),
      departure_date: "2023-08-01",
      return_date: "2023-08-05",
      owner: User.find(5),
    },
    {
      title: "GW屋久島トレッキング",
      image: File.open("./app/assets/images/itinerary_post/yakushima.jpg"),
      departure_date: "2024-05-01",
      return_date: "2024-05-05",
      owner: User.find(5),
    },
  ]
)

Itinerary.find(1).members << User.find(6)
Itinerary.find(1).members << User.find(4)
Itinerary.find(2).members << User.find(7)
Itinerary.find(3).members << User.find(3)
Itinerary.find(4).members << User.find(10)
Itinerary.find(6).members << User.find(9)
Itinerary.find(7).members << User.find(10)
Itinerary.find(8).members << User.find(4)
Itinerary.find(11).members << User.find(10)
Itinerary.find(12).members << User.find(5)
Itinerary.find(12).members << User.find(7)
Itinerary.find(13).members << User.find(8)
Itinerary.find(14).members << User.find(6)
Itinerary.find(15).members << User.find(3)

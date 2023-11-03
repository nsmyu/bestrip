Itinerary.create!(
  [
    {
      title: "シドニー 5泊6日",
      image: File.open("./app/assets/images/itinerary/sydney.jpg"),
      departure_date: "2023-02-01",
      return_date: "2023-02-06",
      owner: User.find(1),
    },
    {
      title: "東京ディズニーランド&シー",
      image: File.open("./app/assets/images/itinerary/disney.jpg"),
      departure_date: "2023-04-01",
      return_date: "2023-04-03",
      owner: User.find(1),
    },
    {
      title: "宮古島 ダイビング旅行",
      image: File.open("./app/assets/images/itinerary/miyako.jpg"),
      departure_date: "2023-07-01",
      return_date: "2023-07-03",
      owner: User.find(1),
    },
    {
      title: "札幌と小樽 2泊3日",
      image: File.open("./app/assets/images/itinerary/otaru.jpg"),
      departure_date: "2022-12-01",
      return_date: "2022-12-04",
      owner: User.find(2),
    },
    {
      title: "スペイン（バルセロナ、グラナダ）",
      departure_date: "2023-04-01",
      return_date: "2023-04-08",
      owner: User.find(2),
    },
    {
      title: "USJと大阪観光",
      image: File.open("./app/assets/images/itinerary/usj.jpg"),
      departure_date: "2023-10-01",
      return_date: "2023-10-03",
      owner: User.find(2),
    },
    {
      title: "東京観光",
      image: File.open("./app/assets/images/itinerary/asakusa.jpg"),
      departure_date: "2023-09-01",
      return_date: "2023-09-03",
      owner: User.find(3),
    },
    {
      title: "シンガポール 3泊4日",
      image: File.open("./app/assets/images/itinerary/merlion.jpg"),
      departure_date: "2023-04-01",
      return_date: "2023-04-04",
      owner: User.find(3),
    },
    {
      title: "トルコ",
      departure_date: "2024-03-01",
      return_date: "2024-03-07",
      owner: User.find(3),
    },
    {
      title: "ベトナム ホーチミンとハノイ",
      departure_date: "2022-06-01",
      return_date: "2022-06-05",
      owner: User.find(4),
    },
    {
      title: "メルボルン一週間の旅",
      image: File.open("./app/assets/images/itinerary/melbourne.jpg"),
      departure_date: "2023-03-01",
      return_date: "2023-03-07",
      owner: User.find(4),
    },
    {
      title: "沖縄旅行（那覇、美ら海水族館）",
      image: File.open("./app/assets/images/itinerary/okinawa.jpg"),
      departure_date: "2023-07-01",
      return_date: "2023-07-04",
      owner: User.find(4),
    },
    {
      title: "バンコク・パタヤビーチ 3泊5日",
      image: File.open("./app/assets/images/itinerary/thailand.jpg"),
      departure_date: "2022-11-01",
      return_date: "2022-11-05",
      owner: User.find(5),
    },
    {
      title: "北海道 旭川から富良野・美瑛",
      image: File.open("./app/assets/images/itinerary/biei.jpg"),
      departure_date: "2023-08-01",
      return_date: "2023-08-05",
      owner: User.find(5),
    },
    {
      title: "GW屋久島トレッキング",
      image: File.open("./app/assets/images/itinerary/yakushima.jpg"),
      departure_date: "2024-05-01",
      return_date: "2024-05-05",
      owner: User.find(5),
    },
  ]
)

Itinerary.find(1).members << User.find(6)
Itinerary.find(2).members << User.find(7)
Itinerary.find(3).members << User.find(3)
Itinerary.find(4).members << User.find(9)
Itinerary.find(4).members << User.find(10)
Itinerary.find(6).members << User.find(10)
Itinerary.find(8).members << User.find(4)
Itinerary.find(9).members << User.find(8)
Itinerary.find(10).members << User.find(1)
Itinerary.find(10).members << User.find(5)
Itinerary.find(12).members << User.find(5)
Itinerary.find(12).members << User.find(7)
Itinerary.find(13).members << User.find(8)
Itinerary.find(14).members << User.find(6)
Itinerary.find(15).members << User.find(3)

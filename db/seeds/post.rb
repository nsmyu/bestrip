Itinerary.all.each do |itinerary|
  next if itinerary.departure_date > Date.new(2024, 1, 1)

  itinerary.posts.new(
    {
      title: itinerary.title,
      itinerary_public: true,
      created_at: itinerary.return_date.since(3.days),
      user: itinerary.owner,
    }
  ).save(validate: false)

  if itinerary.members.count >= 2
    itinerary.posts.new(
      {
        title: "",
        itinerary_public: true,
        created_at: itinerary.return_date.since(4.days),
        user: itinerary.members[1],
      }
    ).save(validate: false)
  end
end

Post.find(1).update(
  {
    caption: "シドニー市内、郊外のスポットも満喫してきました✨\n\n#オーストラリア #シドニー #海外旅行",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/sydney.jpg") }],
  }
)
Post.find(2).update(
  {
    title: "オーストラリア🇦🇺シドニー",
    caption: "シドニーで5日間、ゆったり旅してきました\nコアラ可愛かったな🐨\n\n#オーストラリア #シドニー #タロンガ動物園",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/koala.jpg") }],
  }
)
Post.find(3).update(
  {
    caption: "1日目はディズニーシー、2日目は豊洲や東京駅周辺でいろいろ!楽しかった☺️\n\n#ディズニーシー #東京 #豊洲 #チームラボ",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/disneysea.jpg") }],
  }
)
Post.find(4).update(
  {
    title: "東京🗼ディズニーとチームラボ",
    caption: "夢の国とチームラボ行ってきた!\n豊洲でお寿司も食べたよ🍣\n\n#ディズニーシー #東京 #東京駅 #チームラボ #豊洲市場",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/teamlab.jpg") }],
  }
)
Post.find(5).update(
  {
    caption: "宮古島の海透明度高くて最高だった!\n\n#沖縄 #宮古島 #ダイビング",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/diving.jpg") }]
  }
)
Post.find(6).update(
  {
    title: "宮古島でなつやすみ🏝️",
    caption: "ダイビング目的で宮古島へ。\n伊良部大橋も行ってきました♪\n\n#沖縄 #宮古島 #夏休み #絶景",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/miyako.jpg") }]
  }
)
Post.find(7).update(
  {
    caption: "札幌、小樽周辺を回るプラン。\nすごい寒かったけど、雪景色綺麗だった✨\n\n#北海道 #札幌 #小樽",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/otaru.jpg") }],
  }
)
Post.find(8).update(
  {
    title: "札幌&小樽 北海道グルメ満喫してきた",
    caption: "海鮮、ラーメン、ジンギスカンなど、美味しいものたくさん食べてきました!\n\n#北海道 #札幌",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/sushi.jpg") }],
  }
)
Post.find(9).update(
  {
    caption: "念願のスペイン🇪🇸\nどこも綺麗だったけど、グラナダ特におすすめ!\n\n#スペイン #バルセロナ #グラナダ #絶景 #海外旅行 #一人旅",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/sagrada-familia.jpg") }],
  }
)
Post.find(10).update(
  {
    caption: "1日目はUSJ、2日目は大阪市内観光。\n大阪城すごく綺麗だった✨\n\n#大阪 #USJ #大阪城",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/osakajo.jpg") }],
  }
)
Post.find(11).update(
  {
    title: "USJ行ってきました♪",
    caption: "久々のUSJ楽しかった!\nハリーポッターエリア何回行っても最高✨\n\n#ユニバーサルスタジオジャパン #USJ #大阪",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/usj.jpg") }],
  }
)
Post.find(12).update(
  {
    caption: "東京の有名どころを巡る旅。\nたまにはこんなベタな旅も良い◎\n\n#スカイツリー #浅草寺 #明治神宮 #東京",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/asakusa.jpg") }],
  }
)
Post.find(13).update(
  {
    title: "東京観光一泊二日💫",
    caption: "二日あれば都内けっこういろいろ回れる♪\n\n#スカイツリー #浅草寺 #上野唐物園 #明治神宮 #東京",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/skytree.jpg") }],
  }
)
Post.find(14).update(
  {
    caption: "シンガポールの観光スポット詰め込みプランで行ってきました♪\n\n#シンガポール #マーライオン #ガーデンズ・バイ・ザ・ベイ #セントーサ島",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/merlion.jpg") }],
  }
)
Post.find(15).update(
  {
    title: "シンガポール旅行🇸🇬",
    caption: "憧れのマリーナベイサンズに泊まってきました✨\n\n#シンガポール #東南アジア #海外旅行",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/marina-bay-sands.jpg") }],
  }
)
Post.find(16).update(
  {
    caption: "ハノイの雰囲気すごく好きだった😌\n東南アジア好きな方には超おすすめ◎\n\n#ベトナム #東南アジア #一人旅 #ハロン湾 #絶景",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/ha-long.jpg") }],
  }
)
Post.find(17).update(
  {
    caption: "メルボルンすごくお洒落な街でした\nカフェ巡りがおすすめ◎\n\n#オーストラリア #メルボルン #海外旅行",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/melbourne.jpg") }],
  }
)
Post.find(18).update(
  {
    title: "オーストラリア🇦🇺メルボルン",
    caption: "メルボルンの街と、郊外の観光名所へ。\nグレートオーシャンロードの絶景最高だった!\n\n#オーストラリア #メルボルン #海外旅行 #絶景",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/great-ocean-road.jpg") }],
  }
)
Post.find(19).update(
  {
    caption: "念願の沖縄〜!\nずっと行きたかったハートロックも行けたよ🫶\n\n#沖縄 #那覇 #美ら海水族館",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/okinawa.jpg") }],
  }
)
Post.find(20).update(
  {
    title: "沖縄本島満喫してきた🏝️",
    caption: "国際通り、青の洞窟、美ら海水族館など、沖縄本島満喫プランでした✨\n\n\n#沖縄 #那覇 #恩納村 #美ら海水族館",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/aquarium.jpg") }],
  }
)
Post.find(21).update(
  {
    caption: "アユタヤ遺跡をトゥクトゥクで巡ったの最高だった✨\n\n#タイ #バンコク #東南アジア",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/thailand.jpg") }],
  }
)
Post.find(22).update(
  {
    title: "タイ旅行（バンコク&パタヤ🏖️）",
    caption: "バンコクと、近郊のパタヤビーチにも足を伸ばしました◎\n\n#タイ #バンコク #パタヤ #東南アジア",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/pattaya.jpg") }],
  }
)
Post.find(23).update(
  {
    caption: "旭川から富良野と美瑛を巡るプランで、\n夏の北海道満喫してきました🚗\n\n#北海道 #富良野 #美瑛 #夏休み",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/biei.jpg") }],
  }
)
Post.find(24).update(
  {
    title: "北海道（富良野と美瑛）",
    caption: "青い池、四季彩の丘など、綺麗な景色をたくさん見てきました🌼\n\n#北海道 #富良野 #美瑛",
    photos_attributes: [{ url: File.open("./app/assets/images/itinerary_post/blue-pond.jpg") }],
  }
)

Post.all.each do |post|
  photos = Photo.create(
    [
      { url: File.open("./app/assets/images/itinerary_post/beach.jpg") },
      { url: File.open("./app/assets/images/itinerary_post/food.jpg") },
      { url: File.open("./app/assets/images/itinerary_post/street.jpg") },
    ]
  )
  post.photos << photos
end

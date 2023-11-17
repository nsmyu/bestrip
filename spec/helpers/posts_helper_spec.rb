require 'rails_helper'

RSpec.describe PostsHelper, type: :helper do
  let(:text) { "テスト #タグ1　#タグ2" }

  describe "#link_to_hashtag(text)" do
    it "引数の文字列の中でHASHTAG_REGEXに一致する部分を、posts#searchへのリンクに変換して返すこと" do
      expect(helper.link_to_hashtag(text))
        .to match(/<a.+\shref="\/posts\/search\?keyword=%23%E3%82%BF%E3%82%B01">#タグ1<\/a>/)
        .and match(/<a.+\shref="\/posts\/search\?keyword=%23%E3%82%BF%E3%82%B02">#タグ2<\/a>/)
    end
  end
end

module CommentsHelper
  def time_since_creation(created_at)
    time_elapsed = (Time.current - created_at).round

    if time_elapsed < 60
      return "たった今"
    elsif time_elapsed < (60 * 60)
      return (time_elapsed / 60).to_s + "分前"
    elsif time_elapsed < (60 * 60 * 24)
      return (time_elapsed / (60 * 60)).to_s + "時間前"
    elsif time_elapsed < (60 * 60 * 24 * 7)
      return (time_elapsed / (60 * 60 * 24)).to_s + "日前"
    else
      return (time_elapsed / (60 * 60 * 24 * 7)).to_s + "週間前"
    end
  end
end

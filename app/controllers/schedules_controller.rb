class SchedulesController < ApplicationController
  before_action :authenticate_user!, :authenticate_itinerary_member
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]

  def index
    unsorted_schedules = Itinerary.find(params[:itinerary_id]).schedules.order(:schedule_date)
    @sorted_schedules = unsorted_schedules
      .group_by(&:schedule_date)
      .map do |date, schedules|
        [
          date,
          schedules.partition { |s| s.start_at.nil? }.yield_self do |nils, with_start_at|
            with_start_at.sort_by { |w| w.start_at.strftime("%H:%M") } + nils
          end,
        ]
      end
  end

  def new
    @schedule = Itinerary.find(params[:itinerary_id]).schedules.new
  end

  def create
    @schedule = Itinerary.find(params[:itinerary_id]).schedules.new(schedule_params)
    if @schedule.save
      redirect_to :itinerary_schedules, notice: "新しいスケジュールを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if @schedule.place_id.present?
      place_id = @schedule.place_id

      uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json")
      http_client = Net::HTTP.new(uri.host, uri.port)
      http_client.use_ssl = true

      params = [
        "?place_id=#{place_id}",
        "&fields=name%2Cformatted_address%2Cphotos",
        "&key=#{ENV['GOOGLE_API_KEY']}",
        "&language=ja&region=JP",
      ]

      req = Net::HTTP::Get.new(uri + params.join)
      response = http_client.request(req)
      data = JSON.parse(response.body, symbolize_names: true)

      if data[:error_message].blank?
        @place_name = data[:result][:name]
        @place_address = data[:result][:formatted_address]
        photo_reference = data[:result][:photos][0][:photo_reference]
        @place_photo_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_reference}&key=#{ENV['GOOGLE_API_KEY']}"
      else
        @error_message = "スポット情報が取得できませんでした"
      end
    end
  end

  def edit
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to @schedules, notice: "スケジュール情報を変更しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    deleted_title = @schedule.title
    @schedule.destroy
    redirect_to :itinerary_schedules, notice: "#{deleted_title}を削除しました。"
  end

  private

  def schedule_params
    params.require(:schedule)
      .permit(:title, :schedule_date, :start_at, :end_at, :icon, :place_id, :itinerary_id)
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end

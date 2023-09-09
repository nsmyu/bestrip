class SchedulesController < ApplicationController
  before_action :authenticate_user!, :authenticate_itinerary_member
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  before_action :set_itinerary, except: [:show, :edit, :update, :destroy]

  def index
    unsorted_schedules = Itinerary.find(params[:itinerary_id]).schedules
    @sorted_schedules = unsorted_schedules
      .group_by(&:schedule_date)
      .map do |date, schedules|
        [
          date, schedules.sort_by do |schedule|
            [schedule.start_at, schedule.created_at] || -1
          end,
        ]
      end
  end

  def new
    @schedule = @itinerary.schedules.new
  end

  # def new_with_place
  #   @schedule = @itinerary.schedules.new(schedule_params)
  # end

  def add_place_to_schedule
    place_id = params[:place_id]
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
    @place = client.spot(place_id, language: 'ja')
  end

  def remove_place_from_schedule
    @place = nil
  end

  def create
    @schedule = @itinerary.schedules.new(schedule_params)
    if @schedule.place_id
      place_id = @schedule.place_id if @schedule.place_id
      client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
      @place = client.spot(place_id, language: 'ja')
    end

    if @schedule.save
      redirect_to :itinerary_schedules, notice: "新しいスケジュールを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
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
    if current_user == @schedule.owner
      @schedule.destroy
      redirect_to :schedules, notice: "#{deleted_title}を削除しました。"
    else
      redirect_to :schedules
    end
  end

  private

  def schedule_params
    params.require(:schedule)
      .permit(:title,
              :schedule_date,
              :start_at,
              :end_at,
              :icon,
              :place_name,
              :address,
              :image,
              :place_id,
              :itinerary_id)
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def set_itinerary
    @itinerary = Itinerary.find(params[:itinerary_id])
  end
end

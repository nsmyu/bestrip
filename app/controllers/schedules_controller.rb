class SchedulesController < ApplicationController
  include GooglePlacesApiRequestable

  before_action -> {
    authenticate_user!
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }
  before_action :set_schedule, only: %i(show edit update destroy)

  def index
    schedules = Itinerary.find(params[:itinerary_id]).schedules
    sort_schedules_by_date_time(schedules)
  end

  def new
    @schedule = @itinerary.schedules.new
    if params[:place_id]
      @place_id = params[:place_id]
      get_place_details(@place_id)
      @schedule.title = @place_details[:name]
    end
  end

  def create
    @schedule = @itinerary.schedules.new(schedule_params)
    if @schedule.save
      redirect_to :itinerary_schedules, notice: "新しいスケジュールを作成しました。"
    end
  end

  def show
    if @schedule.place_id.present?
      @place_id = @schedule.place_id
      get_place_details(@place_id)
    end
  end

  def edit
    if @schedule.place_id.present?
      @place_id = @schedule.place_id
      get_place_details(@place_id)
    end
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to :itinerary_schedules, notice: "スケジュール情報を変更しました。"
    end
  end

  def destroy
    @schedule.destroy
    redirect_to :itinerary_schedules, notice: "スケジュールを削除しました。"
  end

  private

  def schedule_params
    params.require(:schedule)
      .permit(:title, :schedule_date, :start_at, :end_at, :icon, :note, :place_id, :itinerary_id)
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end

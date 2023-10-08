class SchedulesController < ApplicationController
  include GooglePlacesApi

  before_action -> {
    authenticate_user!
    set_itinerary
    authenticate_itinerary_member(@itinerary)
  }
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
    @schedule = @itinerary.schedules.new
    if params[:favorite_id]
      @place_id = Favorite.find(params[:favorite_id]).place_id
      get_place_details(@place_id)
      @schedule.title = @place_details[:name]
    end
  end

  def create
    @schedule = @itinerary.schedules.new(schedule_params)
    if @schedule.save
      redirect_to :itinerary_schedules, notice: "新しいスケジュールを作成しました。"
    else
      render :new, status: :unprocessable_entity
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
    else
      render "edit", status: :unprocessable_entity
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
      .permit(:title, :schedule_date, :start_at, :end_at, :icon, :note, :place_id, :itinerary_id)
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end

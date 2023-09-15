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
      .permit(:title, :schedule_date, :start_at, :end_at, :icon, :place_id, :itinerary_id)
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end

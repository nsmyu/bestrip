class SchedulesController < ApplicationController
  before_action :authenticate_user!, :validate_current_user
  before_action :set_schedule, except: [:index, :new, :create]

  def index
    unsorted_schedules = Itinerary.find(params[:itinerary_id]).schedules
    @sorted_schedules = unsorted_schedules
      .group_by(&:schedule_date)
      .map do |date, schedules|
        [
          date, schedules.sort_by do |schedule|
            schedule[:start_at] || -1
          end,
        ]
      end
  end

  def new
    @schedule = Schedule.new
    @itinerary = Itinerary.find(params[:itinerary_id])
  end

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    @schedule = @itinerary.schedules.new(schedule_params)
    if @schedule.save
      redirect_to :schedules, notice: "新しいスケジュールを作成しました。"
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

  def validate_current_user
    itinerary = Itinerary.find(params[:itinerary_id])
    redirect_to :root unless itinerary.members.include?(current_user)
  end

  def schedule_params
    params.require(:schedule)
      .permit(:title,
              :schedule_date, :start_at, :end_at, :icon, :url, :address, :note, :itinerary_id)
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end
end

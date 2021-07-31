class EventsController < ApplicationController
  before_action :connected_user, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]

  def index
    events = show_all_events? ? Event.all : current_user_events
    @events = events.order(created_at: :desc).paginate(page: params[:page])
    @admin_flag = current_user_admin?
  end

  def new
    @event_form = EventForm.new(Event.new(reminders: [Reminder.new, Reminder.new, Reminder.new]))
  end

  def create
    @event_form = EventForm.new(event_params)
    if @event_form.save(current_user_id)
      flash[:success] = "Successfully created."
      redirect_to edit_event_url(@event_form.event)
    else
      flash.now[:danger] = "Failed to create."
      render 'new'
    end
  end

  def edit
    @event_form = EventForm.new(Event.find(params[:id]))
  end

  def update
    @event_form = EventForm.new(event_params)
    if @event_form.update(params[:id])
      flash[:success] = "Successfully updated."
      redirect_to edit_event_url(@event_form.event)
    else
      flash.now[:danger] = "Failed to update."
      render 'edit'
    end
  end

  def destroy
    Event.find(params[:id]).destroy
    flash[:success] = "Successfully deleted."
    redirect_to events_url
  end

  private
    def event_params
      event = params.require(:event_form).permit(:title, :description, :start_date, :end_date, :start_time, :end_time, :day_of_week, :with_order, :week_of_month, :day_of_month, :start_datetime, reminders_attributes: [:id, :number, :unit, :remind_at])
      reminders = event.delete(:reminders_attributes)

      event[:reminders] = []
      reminders.values.each do |reminder|
        event[:reminders] << Reminder.new(reminder)
      end

      event
    end

    def connected_user
      unless connected?
        flash[:danger] = "Invalid session."
        redirect_to destroy_sessions_url(type: :session)
      end
    end

    def correct_user
      event = Event.find(params[:id])
      unless current_user_id?(event.user_id) || current_user_admin?
        flash[:danger] = "Invalid session."
        redirect_to destroy_sessions_url(type: :session)
      end
    end
end

class EventForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :title, :description, :start_date, :end_date, :start_time, :end_time, :day_of_week, :with_order, :week_of_month, :day_of_month
  attr_accessor :reminders_attributes

  # validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 120 }

  # VALID_DATE_REGEX = /\A[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])\z/
  # validates :start_date, allow_blank: true, format: { with: VALID_DATE_REGEX }
  # validates :end_date, allow_blank: true, format: { with: VALID_DATE_REGEX }

  # VALID_TIME_REGEX = /\A[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] \+([01][0-9]|2[0-3])[0-5][0-9]\z/
  # validates :start_time, allow_blank: true, format: { with: VALID_TIME_REGEX }
  # validates :end_time, allow_blank: true, format: { with: VALID_TIME_REGEX }

  validates :day_of_week, allow_blank: true, numericality: { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 6 }
  validates :with_order, allow_blank: true, numericality: { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5 }
  validates :week_of_month, allow_blank: true, numericality: { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 6 }
  VALID_DAY_OF_MONTH_REGEX = /\A(-1|([1-9]|[12][0-9]|3[01]))\z/
  validates :day_of_month, allow_blank: true, numericality: { :only_integer => true }, format: { with: VALID_DAY_OF_MONTH_REGEX }

  # VALID_DATE_TIME_REGEX = /\A[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]) ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] \+([01][0-9]|2[0-3])[0-5][0-9]\z/
  # validates :start_datetime, allow_blank: true, format: { with: VALID_DATE_TIME_REGEX }
  # validates :end_datetime, allow_blank: true, format: { with: VALID_DATE_TIME_REGEX }
  # validates :start_datetime, presence: true
  # validates :end_datetime, presence: true

  # validates :event_id, presence: true
  # validates :number, presence: true, numericality: { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 59 }
  # validates :unit, presence: true, numericality: { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 3 }

  validate :unavailable_dates
  validate :unusable_combinations
  validate :unavailable_reminders

  # memo: I have to rewrite the error message properly.

  def unavailable_dates
    errors[:base] << "Unavailable dates.(-1)" if start_date.present? && start_date < Time.zone.today
    errors[:base] << "Unavailable dates.(-2)" if (start_date.present? && end_date.present?) && start_date >= end_date
    errors[:base] << "Unavailable dates.(-3)" if (start_time.present? && end_time.present?) && start_time >= end_time
    errors[:base] << "Unavailable dates.(-4)" if (day_of_week.present? && week_of_month.present?) && ([0,1].exclude?(day_of_week) && week_of_month == 6)
  end

  def unusable_combinations
    errors[:base] << "Unusable combinations.(-1)" if (start_date.blank? && end_date.present?) || (start_time.blank? && end_time.present?)
    errors[:base] << "Unusable combinations.(-2)" if (start_date.blank? && start_time.blank?) && (day_of_week.blank? && with_order.blank? && week_of_month.blank? && day_of_month.blank?)
    errors[:base] << "Unusable combinations.(-3)" if start_date.present? && (day_of_week.present? || day_of_month.present?)
    errors[:base] << "Unusable combinations.(-4)" if day_of_week.present? && day_of_month.present?
    errors[:base] << "Unusable combinations.(-5)" if day_of_week.blank? && with_order.present?
    errors[:base] << "Unusable combinations.(-6)" if day_of_week.blank? && week_of_month.present?
  end

  def unavailable_reminders
    reminders.each do |reminder|
      errors[:base] << "Unavailable reminder.(-1)" if reminder['number'].blank? || (reminder['number'] < 0 || reminder['number'] > 59)
      errors[:base] << "Unavailable reminder.(-2)" if reminder['unit'].blank? || (reminder['unit'] < 1 || reminder['unit'] > 3)
    end
  end

  def initialize(event = nil)
    @title = event[:title]
    @description = event[:description]
    @start_date = event[:start_date]&.to_date
    @end_date = event[:end_date]&.to_date
    @start_time = event[:start_time]&.in_time_zone
    @end_time = event[:end_time]&.in_time_zone
    @day_of_week = event[:day_of_week]
    @with_order = event[:with_order]
    @week_of_month = event[:week_of_month]
    @day_of_month = event[:day_of_month]

    if(event.is_a?(Event))
      @reminders_attributes = event.reminders
    else
      @reminders_attributes = event[:reminders]
    end
  end

  def reminders
    @reminders_attributes
  end

  def save(user_id)
    return false if invalid?

    event = nil

    ActiveRecord::Base.transaction do
      event = User.find(user_id).events.build(event_part_params)
      event.preprocess!.save!

      reminders.each do |reminder_params|
        reminder = event.reminders.build(number: reminder_params[:number], unit: reminder_params[:unit])
        reminder.preprocess!.save!
      end
    end

    @event_id = event.id

    true
  end

  def update(event_id)
    return false if invalid?

    event = nil

    ActiveRecord::Base.transaction do
      event = Event.find(event_id)
      event.assign_attributes(event_part_params)
      event.preprocess!.save!

      reminders.each do |reminder_params|
        reminder = event.reminders.find(reminder_params[:id])
        reminder.assign_attributes(number: reminder_params[:number], unit: reminder_params[:unit])
        reminder.preprocess!.save!
      end
    end

    @event_id = event.id

    true
  end

  def event
    Event.find(@event_id)
  end

  private

    def event_part_params
      {
        title: title, description: description,
        start_date: start_date, end_date: end_date, start_time: start_time, end_time: end_time,
        day_of_week: day_of_week, with_order: with_order, week_of_month: week_of_month, day_of_month: day_of_month
      }
    end
end
class Event < ApplicationRecord
  belongs_to :user
  has_many :reminders, dependent: :destroy
  # accepts_nested_attributes_for :reminders

  validates :user_id, presence: true
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

  validate :unavailable_dates
  validate :unusable_combinations

  def unavailable_dates
    errors[:base] << "Unavailable dates.(-1)" if start_date.present? && start_date < Time.zone.today
    errors[:base] << "Unavailable dates.(-2)" if (start_date.present? && end_date.present?) && start_date >= end_date
    errors[:base] << "Unavailable dates.(-3)" if (start_time.present? && end_time.present?) && start_time >= end_time
    errors[:base] << "Unavailable dates.(-4)" if (day_of_week.present? && week_of_month.present?) && ([0,1].exclude?(day_of_week) && week_of_month == 6)
  end

  def unusable_combinations
    errors[:base] << "Unusable combinations.(-1)" if (start_date.blank? && end_date.present?) || (start_time.blank? && end_time.present?)
    errors[:base] << "Unusable combinations.(-2)" if (start_date.blank? && start_time.blank?) && (day_of_week.blank? && day_of_month.blank?)
    errors[:base] << "Unusable combinations.(-3)" if start_date.present? && (day_of_week.present? || day_of_month.present?)
    errors[:base] << "Unusable combinations.(-4)" if day_of_week.present? && day_of_month.present?
    errors[:base] << "Unusable combinations.(-5)" if day_of_week.blank? && with_order.present?
    errors[:base] << "Unusable combinations.(-6)" if day_of_week.blank? && week_of_month.present?
  end

  def preprocess!
    start_datetime!
    end_datetime!
    self
  end

  def self.word(line_id_digest, word)
    result = ""
    events = Event.joins(:user).where('line_id_digest = ? AND (title LIKE ? OR description LIKE ?)', line_id_digest, "%#{word}%", "%#{word}%")
    events.order(:start_datetime).each do |event|
      result += "【" + event.title + "】\n" +
                  (event.description.present? ? event.description + "\n" : "") +
                  event.datetime_to_string + "\n" +
                  "\n"
    end
    result = 'No results found.' if result.blank?
    result.rstrip
  end

  def self.search(line_id_digest, from = nil, to = nil)
    result = ""
    if from.present? && to.present?
      events = Event.joins(:user).select('title,description,start_datetime,end_datetime,start_time').where('line_id_digest = ? AND end_datetime >= ? AND end_datetime <= ?', line_id_digest, from, to)
    else
      events = Event.joins(:user).select('title,description,start_datetime,end_datetime,start_time').where('line_id_digest = ?', line_id_digest)
    end
    events.order(:start_datetime).each do |event|
      result += "【" + event.title + "】\n" +
                  (event.description.present? ? event.description + "\n" : "") +
                  event.datetime_to_string + "\n" +
                  "\n"
    end
    result = 'No results found.' if result.blank?
    result.rstrip
  end

  def datetime_to_string
    if start_datetime == end_datetime
      result = I18n.l(start_datetime)
    elsif start_datetime.to_date == end_datetime.to_date
      if start_time.present?
        result = I18n.l(start_datetime) + " - " + I18n.l(end_datetime, format: :time)
      else
        result = I18n.l(start_datetime.to_date)
      end
    else
      if start_time.present?
        result = I18n.l(start_datetime) + "\n" + I18n.l(end_datetime)
      else
        result = I18n.l(start_datetime.to_date) + "\n" + I18n.l(end_datetime.to_date)
      end
    end
    status = end_datetime < Time.zone.now ? " [Ended]" : ""
    result + status
  end

  private
    def wdays
      [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
    end

    def date_from_wday
      start = start_time.present? ? Time.zone.today + start_time.seconds_since_midnight.second : Time.zone.today.end_of_day
      base = start > Time.zone.now ? Time.zone.today : Time.zone.tomorrow
      date = base.wday == day_of_week ? base : base.next_occurring(wdays[day_of_week])
      date += start_time.seconds_since_midnight.second if start_time.present?
      date
    end

    def date_from_wday_and_order
      start = start_time.present? ? Time.zone.today + start_time.seconds_since_midnight.second : Time.zone.today.end_of_day
      base = start > Time.zone.now ? Time.zone.today : Time.zone.tomorrow
      beginning_of_month = base.beginning_of_month
      date = nil
      loop do
        date = beginning_of_month.wday == day_of_week ? beginning_of_month : beginning_of_month.next_occurring(wdays[day_of_week])
        date += (with_order - 1).weeks
        break if base <= date && date.month == beginning_of_month.month
        beginning_of_month += 1.month
      end
      date += start_time.seconds_since_midnight.second if start_time.present?
      date
    end

    def date_from_wday_and_week
      start = start_time.present? ? Time.zone.today + start_time.seconds_since_midnight.second : Time.zone.today.end_of_day
      base = start > Time.zone.now ? Time.zone.today : Time.zone.tomorrow
      beginning_of_month = base.beginning_of_month
      date = nil
      loop do
        date = beginning_of_month + (week_of_month - 1).weeks
        date = date.beginning_of_week(:sunday)
        date = date.wday == day_of_week ? date : date.next_occurring(wdays[day_of_week])
        break if base <= date && date.month == beginning_of_month.month
        beginning_of_month += 1.month
      end
      date += start_time.seconds_since_midnight.second if start_time.present?
      date
    end

    def date_from_day
      start = start_time.present? ? Time.zone.today + start_time.seconds_since_midnight.second : Time.zone.today.end_of_day
      base = start > Time.zone.now ? Time.zone.today : Time.zone.tomorrow
      beginning_of_month = base.beginning_of_month
      date = nil
      loop do
        date = beginning_of_month + (day_of_month - 1).days
        break if base <= date && date.month == beginning_of_month.month
        beginning_of_month += 1.month
      end
      date += start_time.seconds_since_midnight.second if start_time.present?
      date
    end

    def date_from_time(base, time)
      date = base
      date = date.to_date + time.seconds_since_midnight.seconds if time.present?
      date
    end

    def start_datetime!
      # return nil if invalid?

      case date_type
      when :range
        datetime = date_from_time(start_date, start_time)
      when :oneday
        datetime = date_from_time(start_date, start_time)
      when :daily
        datetime = date_from_time(Time.zone.today, start_time)
        datetime += 1.day if datetime <= Time.zone.now
      when :weekly
        datetime = date_from_wday
      when :day_of_week1
        datetime = date_from_wday_and_order
      when :day_of_week2
        datetime = date_from_wday_and_week
      when :monthly
        datetime = date_from_day
      else
        raise "unexpected date type"
      end

      self.start_datetime = datetime
    end

    def end_datetime!
      # return nil if invalid?

      if end_date.present?
        date = end_date
      else
        date = self.start_datetime
      end
      if end_time.present?
        time = end_time
      else
        time = start_time.present? ? start_time : "23:59:59".in_time_zone
      end
      datetime = date_from_time(date, time)

      self.end_datetime = datetime
    end

    def date_type
      # return nil if invalid?

      if start_date.present? && end_date.present? && (day_of_week.blank? && with_order.blank? && week_of_month.blank? && day_of_month.blank?)
        :range
      elsif start_date.present? && (day_of_week.blank? && with_order.blank? && week_of_month.blank? && day_of_month.blank?)
        :oneday
      elsif start_time.present? && (day_of_week.blank? && with_order.blank? && week_of_month.blank? && day_of_month.blank?)
        :daily
      elsif day_of_week.present? && with_order.blank? && week_of_month.blank? && day_of_month.blank?
        :weekly
      elsif day_of_week.present? && with_order.present? && week_of_month.blank? && day_of_month.blank?
        :day_of_week1
      elsif day_of_week.present? && with_order.blank? && week_of_month.present? && day_of_month.blank?
        :day_of_week2
      elsif day_of_week.blank? && with_order.blank? && week_of_month.blank? && day_of_month.present?
        :monthly
      else
        :unkown
      end
    end
end

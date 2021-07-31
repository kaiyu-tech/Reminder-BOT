class Reminder < ApplicationRecord
  belongs_to :event

  validates :event_id, presence: true
  validates :number, presence: true, numericality: { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 59 }
  validates :unit, presence: true, numericality: { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 3 }

  def preprocess!
    remind_at!
    self
  end

  def remind_time
    if unit == 1 # minute
      temp = number.minutes
    elsif unit == 2 # hour
      temp = number.hours
    elsif unit == 3 # day
      temp = number.days
    end

    temp
  end

  private

    def remind_at!
      self.remind_at = event.start_datetime - remind_time
    end
end

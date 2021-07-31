require 'line_notify'

class LineNotifyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # notify = LineNotify.new(ENV['LINE_NOTIFY_TOKEN'])
    # options = {
    #   message: "\n" +
    #     Time.zone.now.to_s
    # }
    # notify.ping(options)

    now = Time.zone.now
    User.valid_users.where('notify_token_encrypt IS NOT NULL').each do |user|
      reminded_at = user.reminded_at || now.midnight
      user.events.where('start_datetime > ?', reminded_at).order(start_datetime: :asc).each do |event|
        if event.start_datetime <= now
          line_notify(user, event, 0.seconds, now)
        else
          reminder = event.reminders.where('remind_at > ? AND remind_at <= ?', reminded_at, now).order(remind_at: :desc).first
          line_notify(user, event, reminder.remind_time, now) if reminder.present?
          next
        end
      end

      user.events.where('start_date IS NULL AND end_datetime <= ?', now).each do |event|
        event.preprocess!.save!
        event.reminders.all.each do |reminder|
          reminder.preprocess!.save!
        end
      end
    end
  end

  private

    def line_notify(user, event, remind_time, now)
      notify = LineNotify.new(user.notify_token)
      options = {
        message: "\n" +
          # "Owner: " + user.line_name + "\n" +
          "Title: " + event.title + "\n" +
          (event.description.present? ? "Description: " + event.description + "\n" : "") +
          "Date: " + event.datetime_to_string + "\n" +
          "Event " + (remind_time != 0.seconds ? remind_time.inspect + " later." : " now.")
      }
      notify.ping(options)
      user.update!(reminded_at: now) if user.reminded_at != now
    end
end

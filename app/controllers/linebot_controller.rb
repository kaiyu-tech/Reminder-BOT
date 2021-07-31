require 'line/bot'
require 'line_notify'
require 'nkf'

class LinebotController < ApplicationController
  # Disable CSRF token authentication
  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV['LINE_CHANNEL_ID']
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)
    events.each { |event|
      line_id = event['source']['userId']
      line_id_digest = User.digest(line_id)
      line_name = display_name(event['source'])
      reply_token = event['replyToken']

      case event
      when Line::Bot::Event::Follow
        if User.first.nil?
          User.register(line_id, line_name, true, true)
          text = "You have been registered as an administrator."
        else
          text = "Please say 'command' first."
        end

        reply_message(client, reply_token, text)

      when Line::Bot::Event::Unfollow
        #

      when Line::Bot::Event::Postback
        if event['postback']['data'].start_with?("register") then
          flag = User.register(line_id, line_name, false, true)
          text = flag ? 'You have successfully registered.' : 'You have failed to register.'

          reply_message(client, reply_token, text)
        end

      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          command = NKF.nkf("-w -Z1", event.message['text'])

          if command == "bye" || command == "ばいばい" then
            if event['source']['type'] == "group"
              client.leave_group(event['source']['groupId'])
            elsif event['source']['type'] == "room"
              client.leave_room(event['source']['roomId'])
            end

            print "Debug: " + "type = #{event['source']['type']}, command = #{command}" if Rails.env.test?

          elsif command == "command" || command == "こまんど" then
            user = User.search(line_id)

            if user.nil?
              message = {
                type: "flex",
                altText: "Commands",
                contents: {
                  type: "carousel",
                  contents: [{
                    'type': "bubble",
                    'footer': {
                      'type': "box",
                      'layout': "vertical",
                      'spacing': "sm",
                      'contents': [
                        {
                          'type': "button",
                          'style': "primary",
                          'height': "sm",
                          'action': {
                            'type': "postback",
                            'label': "Register",
                            'data': "register",
                          }
                        }
                      ],
                      'flex': 0
                    }
                  }]
                }
              }
            elsif user.admin?
              message = {
                type: "flex",
                altText: "Commands",
                contents: {
                  type: "carousel",
                  contents: [{
                    'type': "bubble",
                    'footer': {
                      'type': "box",
                      'layout': "vertical",
                      'spacing': "sm",
                      'contents': [
                        {
                          'type': "button",
                          'style': "primary",
                          'height': "sm",
                          'action': {
                            'type': "uri",
                            'label': "Show events (All)",
                            'uri': "https://liff.line.me/" + ENV['LIFF_CHANNEL_URL'] + "/?all=true"
                          }
                        },
                        {
                          'type': "button",
                          'style': "primary",
                          'height': "sm",
                          'action': {
                            'type': "uri",
                            'label': "Show events",
                            'uri': "https://liff.line.me/" + ENV['LIFF_CHANNEL_URL']
                          }
                        },
                        {
                          'type': "button",
                          'style': "primary",
                          'height': "sm",
                          'action': {
                            'type': "uri",
                            'label': "Sidekiq",
                            'uri': ENV['HEROKU_URL'] + "sidekiq?openExternalBrowser=1"
                          }
                        }
                      ],
                      'flex': 0
                    }
                  }]
                }
              }
            else
              message = {
                type: "flex",
                altText: "Commands",
                contents: {
                  type: "carousel",
                  contents: [{
                    'type': "bubble",
                    'footer': {
                      'type': "box",
                      'layout': "vertical",
                      'spacing': "sm",
                      'contents': [
                        {
                          'type': "button",
                          'style': "primary",
                          'height': "sm",
                          'action': {
                            'type': "uri",
                            'label': "Show events",
                            'uri': "https://liff.line.me/" + ENV['LIFF_CHANNEL_URL']
                          }
                        }
                      ],
                      'flex': 0
                    }
                  }]
                }
              }
            end

            client.reply_message(event['replyToken'], message)

          elsif command == "today" || command == "きょう" then
            text = Event.search(line_id_digest, Time.zone.now, Time.zone.today.end_of_day)
            reply_message(client, reply_token, text)

            print "Debug: " + text if Rails.env.test?

          elsif command == "tomorrow" || command == "あした" then
            text = Event.search(line_id_digest, Time.zone.tomorrow.midnight, Time.zone.tomorrow.end_of_day)
            reply_message(client, reply_token, text)

            print "Debug: " + text if Rails.env.test?

          elsif command == "todaytomorrow" || command == "きょうあした" then
            text = Event.search(line_id_digest, Time.zone.now, Time.zone.tomorrow.end_of_day)
            reply_message(client, reply_token, text)

            print "Debug: " + text if Rails.env.test?

          elsif command == "thisweek" || command == "こんしゅう" then
            text = Event.search(line_id_digest, Time.zone.now, Time.zone.now.end_of_week(:sunday))
            reply_message(client, reply_token, text)

            print "Debug: " + text if Rails.env.test?

          elsif command == "nextweek" || command == "らいしゅう" then
            text = Event.search(line_id_digest, Time.zone.now.beginning_of_week(:sunday) + 1.week, Time.zone.now.end_of_week(:sunday) + 1.week)
            reply_message(client, reply_token, text)

            print "Debug: " + text if Rails.env.test?

          elsif command == "thismonth" || command == "こんげつ" then
            text = Event.search(line_id_digest, Time.zone.now, Time.zone.now.end_of_month)
            reply_message(client, reply_token, text)

            print "Debug: " + text if Rails.env.test?

          elsif command == "nextmonth" || command == "らいげつ" then
            text = Event.search(line_id_digest, Time.zone.now.next_month.beginning_of_month, Time.zone.now.next_month.end_of_month)
            reply_message(client, reply_token, text)

            print "Debug: " + text if Rails.env.test?

          elsif command.start_with?("?") then
            word = event.message['text']
            word.slice!(0)

            text = Event.word(line_id_digest, word)
            reply_message(client, reply_token, text)

            print "Debug: " + text if Rails.env.test?

          end
        end
      end
    }

    # Don't forget to return a successful response
    head :ok
  end

  def notify
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

    def display_name(source)
      return "line_name_test_dummy" if Rails.env.test?

      line_id = source['userId']
      if source['type'] == "group"
        res = client.get_group_member_profile(source['groupId'], line_id)
      elsif source['type'] == "room"
        res = client.get_room_member_profile(source['roomId'], line_id)
      else
        res = client.get_profile(line_id)
      end

      JSON.parse(res.body)['displayName']
    end

    def reply_message(client, reply_token, text)
      message = {
        type: "text",
        text: text
      }

      client.reply_message(reply_token, message)
    end

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
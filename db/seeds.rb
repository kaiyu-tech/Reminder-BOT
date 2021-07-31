include SessionsHelper

if Rails.env.development?
  User.create!(line_id_digest: User.digest("line_id_admin"),
                        line_name: "line_id_admin",
                        admin: true,
                        activate: true,
                        expires_in: nil,
                        notify_token_encrypt: User.encrypt("notify_token_admin"),
                        reminded_at: nil)

  user_1 = User.create!(line_id_digest: User.digest("line_id_user_1"),
                        line_name: "line_name_user_1",
                        admin: false,
                        activate: true,
                        expires_in: nil,
                        notify_token_encrypt: User.encrypt("notify_token_user_1"),
                        reminded_at: nil)

  2.upto(35) do |n|
    User.create!(line_id_digest: User.digest("line_id_user_#{n}"), line_name: "line_name_user_#{n}", admin: false, activate: false, expires_in: nil)
  end

  # user_1
  20.times do |n|
    event = user_1.events.build(
      title: "title_#{n}",
      description: "description_#{n}",
      start_date: '2022-01-01',
      end_date: nil,
      start_time: nil,
      end_time: nil,
      day_of_week: nil,
      week_of_month: nil,
      day_of_month: nil
      )
    event.preprocess!.save!
  end
elsif Rails.env.production?
  # You need to have registered administrator and one user first.
  user_1 = User.where(admin: false).order(:created_at).first
end

event = user_1.events.build(
  title: '元旦',
  description: '元旦',
  start_date: '2022-01-01',
  end_date: nil,
  start_time: '0:00:00 +0900',
  end_time: nil,
  day_of_week: nil,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '愛鳥週間',
  description: '5月10日から5月16日',
  start_date: '2022-05-10',
  end_date: '2022-05-16',
  start_time: nil,
  end_time: nil,
  day_of_week: nil,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '起床',
  description: '起床しましょう',
  start_date: nil,
  end_date: nil,
  start_time: '08:00:00 +0900',
  end_time: nil,
  day_of_week: nil,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '就寝',
  description: '就寝しましょう',
  start_date: nil,
  end_date: nil,
  start_time: '22:00:00 +0900',
  end_time: nil,
  day_of_week: nil,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '定例会議',
  description: '技術部定例会議',
  start_date: nil,
  end_date: nil,
  start_time: '13:00:00 +0900',
  end_time: '13:20:00 +0900',
  day_of_week: 2,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '可燃ゴミの日',
  description: '毎週月曜日と金曜日',
  start_date: nil,
  end_date: nil,
  start_time: '08:00:00 +0900',
  end_time: nil,
  day_of_week: 1,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '可燃ゴミの日',
  description: '毎週月曜日と金曜日',
  start_date: nil,
  end_date: nil,
  start_time: '08:00:00 +0900',
  end_time: nil,
  day_of_week: 5,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '瓶、缶、ペットボトルの日',
  description: '毎週火曜日',
  start_date: nil,
  end_date: nil,
  start_time: '08:00:00 +0900',
  end_time: nil,
  day_of_week: 2,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: 'プラスチックの日',
  description: '毎週木曜日',
  start_date: nil,
  end_date: nil,
  start_time: '08:00:00 +0900',
  end_time: nil,
  day_of_week: 4,
  with_order: nil,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '段ボールの日',
  description: '第一、第三火曜日',
  start_date: nil,
  end_date: nil,
  start_time: '08:00:00 +0900',
  end_time: nil,
  day_of_week: 2,
  with_order: 1,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '段ボールの日',
  description: '第一、第三火曜日',
  start_date: nil,
  end_date: nil,
  start_time: '08:00:00 +0900',
  end_time: nil,
  day_of_week: 2,
  with_order: 3,
  week_of_month: nil,
  day_of_month: nil
  )
event.preprocess!.save!

event = user_1.events.build(
  title: '給料日',
  description: '給料日',
  start_date: nil,
  end_date: nil,
  start_time: nil,
  end_time: nil,
  day_of_week: nil,
  with_order: nil,
  week_of_month: nil,
  day_of_month: 25
  )
event.preprocess!.save!

Event.all.each do |e|
  reminder = e.reminders.build(number: 30, unit: 1) # 30 min
  reminder.preprocess!.save!

  reminder = e.reminders.build(number: 1, unit: 2) # 1 hour
  reminder.preprocess!.save!

  reminder = e.reminders.build(number: 1, unit: 3) # 1 day
  reminder.preprocess!.save!
end
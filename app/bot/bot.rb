require 'bot_helper'
# contains bot logic

scheduler = Rufus::Scheduler.new

Bot.on :postback do |postback|
  payload = postback.payload
  if payload == 'tutorial'
    tutorial(postback.sender.to_i)
  elsif payload == 'show_reminders'
    show_reminders(postback.sender["id"])
  elsif payload.include?('delete')
    scheduler_id = payload[7..-1]
    delete_event(scheduler, scheduler_id)
  end

end

Bot.on :message do |message|
  @user = User.find(message.sender['id'])
  # maybe relegate the below conditionals in its own method: handle_reminders
  if message.text.downcase.include?("remind")
    nick = Nickel.parse(message.text)
    event_msg = format_message(nick.message)
    if nick.occurrences.empty?
      bot_send(@user.id, "I'll set a reminder to #{event_msg}, but can you be more specific about the date?")
    else
      event_date = parse_date(nick.occurrences[0])
      event_time = parse_time(nick.occurrences[0])

      new_event = Event.create(user_id: @user.id, message: event_msg, event_date: event_date + " " + event_time)

      reminder_id = scheduler.at(event_date + " " + event_time) do
        bot_send(new_event.user.id, "REMINDER: #{new_event.message}")
      end
      bot_send(new_event.user.id, "Setting your reminder: #{new_event.message} at #{new_event.event_date}")
      new_event.update(scheduler_id: reminder_id)
    end

    # scheduler event here
    # add to the Event database here, create a variable attached to the scheduler action
    # to get the schedule id and add it to the database
    # reference user timezone during the schedule Action

    #
    # event_date = parse_date(nick.occurrences[0])
    # event_time = parse_time(nick.occurrences[0])
    # @event = Event.new(user_id: @user.id, message: event_msg, event_date: event_date)
    # bot_send(@user_id, "Cool, got it. When do you want to be reminded?")

  # elsif !Nickel.parse(message.text).occurrences.empty?
    # confirmation flow

    # ok so this message flow has no reference :( it's supposed to be for step 4 of this process:
    # 1. user: "Remind me to pick up a package on Friday at 12"
    # 2. bot: ok cool how far in advance do you want to be reminded? say "2 hours" for two hours in advance
    # 3. user: 2 hours
    # 4. wait what event are you talking about again??????
    # can we save an event to the database and then have a user.current_event_reference of some sort to refer back to it and then save a reminder later?
  else
    bot_send(@user.id, "Oops, I didn't understand that. Can we start over?")
  end
end

def parse_date(occurrence)
  occurrence.start_date.to_date.to_s.gsub("-", "/")
end

def parse_time(occurrence)
  occurrence.start_time.time.scan(/.{2}/).join(":")
end

def tutorial(user_id)
  bot_type(user_id)
  sleep(2)
  bot_send(user_id, "You can send me any message like this: \"Remind me to do X in 5 hours\"")
  bot_type(user_id)
  sleep(2)
  bot_send(user_id, "You can even use exact dates: \"Remind me to volunteer at the food shelter next Saturday.")
  bot_type(user_id)
  sleep(2)
  bot_send(user_id, "Or: \"Remind me to rent a timeshare on May 5\" Feel free to experiment!")
  bot_type(user_id)
  sleep(2)
  bot_send(user_id, "You can run this tutorial again using the navigation menu on the bottom left corner alongside other options!")
end


def show_reminders(user_id)
  @user = User.find(user_id)
  bot_send(@user.id, "Here's a list of all your reminders. Click the buttons below to edit or delete them!")
  @user.events.each_with_index do |reminder, index|
    Bot.deliver({
      recipient: {
        id: @user.id
      },
      message: {
        attachment: {
          type: "template",
          payload: {
            template_type: "button",
            text: "#{index + 1}: #{reminder.message} at #{reminder.event_date}",
            buttons: [{
              type: "postback",
              title: "Delete",
              payload: "delete #{reminder.scheduler_id}"
              }]
          }
        }
      }}, access_token: ENV['ACCESS_TOKEN'])
    bot_type(@user.id)
    sleep(0.76258739)
  end
end

def delete_event(scheduler, scheduler_id)
  event = Event.where(scheduler_id: scheduler_id)[0]
  scheduler.unschedule(scheduler_id)
  bot_send(event.user.id, "Unscheduling that reminder!")
  event.destroy
end

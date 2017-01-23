require 'bot_helper'
# contains bot logic

Bot.on :postback do |postback|
  @user = User.find_or_create_by(id: postback.sender['id'])
  @user.update_attributes
  case postback.payload
  when 'tutorial'
    tutorial(@user.id)
  when 'show_reminders'
    show_reminders(@user.id)
  end
end

Bot.on :message do |message|
  @user = User.find(message.sender['id'])
  # maybe relegate the below conditionals in its own method: handle_reminders
  if message.text.downcase.include?("remind")
    event_msg = format_message(message.text)
    nick = Nickel.parse(message.text)
    if nick.occurrences.empty?
      bot_send(@user.id, "I'll set a reminder to #{event_msg}, but can you be more specific about the date?")
    else
      event_date = parse_date(nick.occurrences[0])
      event_time = parse_time(nick.occurrences[0])
      @event = Event.new(user_id: @user.id, message: event_msg, event_date: event_date)
      bot_send(@user_id, "Cool, got it. When do you want to be reminded?")
    end
  elsif !Nickel.parse(message.text).occurrences.empty?
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
  bot_send(user_id, "Here's a list of all your reminders. Click the buttons below to edit or delete them!")
  @user.events.each_with_index do |reminder, index|
    Bot.deliver({
      recipient: {
        id: user_id
      },
      message: {
        text: "#{index+1}. #{reminder.text}, scheduled at #{reminder.event_date}.",
        quick_replies: [
          {content_type: "text",
          title: "Edit",
          payload: "edit_event"},
          {content_type: "text",
          title: "Delete",
          payload: "delete_event"}
        ]
      }
    }, access_token: ENV['ACCESS_TOKEN'])
  end
end

def edit_event

end

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
      # edit_date
    else
      # scheduler event here
    end
  end
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
  puts "Showing all reminders!"
end

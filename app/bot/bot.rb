require 'bot_helper'
# contains bot logic

Bot.on :message do |message|
  message.reply(text: message.text)
end


def show_help
  puts "Helping!"
end

def show_reminders
  puts "Showing all reminders!"
end

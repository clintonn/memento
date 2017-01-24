require 'bot_helper'
require 'postbacks'
# contains bot logic

scheduler = Rufus::Scheduler.new

Bot.on :postback do |postback|
  payload = postback.payload
  if payload == 'tutorial'
    user = User.find_or_create_by(id: postback.sender["id"])
    user.update_attributes
    tutorial(postback.sender["id"])
  elsif payload == 'show_reminders'
    show_reminders(postback.sender["id"])
  elsif payload == 'cyberbully'
    cyberbully(postback.sender["id"])
  elsif payload.include?('delete')
    scheduler_id = payload[7..-1]
    delete_event(scheduler, scheduler_id)
  elsif payload == 'destroy all'
    Bot.deliver({recipient: { id: postback.sender["id"] },
    message: {
      attachment: {
        type: 'template',
        payload: {
          template_type: "button",
          text: "WAIT ARE YOU SURE???",
          buttons: [
            { type: "postback", title: ">>>🚮<<<", payload: "yes destroy all"},
          { type: "postback", title: "jk", payload: "nope"}
            ]
          }
        }
      }
    }, access_token: ENV['ACCESS_TOKEN'])
  elsif payload == 'nope'
    bot_send(postback.sender["id"], "Cool: keeping your reminders.")
  elsif payload == 'yes destroy all'
    destroy_all(scheduler, postback.sender["id"])
  end

end

Bot.on :message do |message|
  nick = Nickel.parse(message.text)
  if message.text.downcase.include?("remind")
    event_msg = format_message(nick.message)
    new_event = Event.create(user_id: message.sender['id'], message: event_msg)
    if nick.occurrences.empty?
      bot_send(message.sender['id'], "Can you be more specific about the time and day? You can say something like \"8 pm today\" and I'll handle the rest!")
    else
      make_event(scheduler, message.sender['id'], message.text)
    end
  elsif nick.occurrences
    make_event(scheduler, message.sender['id'], User.find(message.sender['id']).events.last.message + " at " + message.text)
    # bot_send(message.sender['id'], "cool")
  else
    bot_send(message.sender['id'], "I am but a humble robot. My only purpose is to schedule tasks. Please send me reminder commands starting with \"remind me.\"")
    message.reply(
      attachment: {
      type: 'image',
      payload: {
      url: 'http://i.imgur.com/IxC2SCj.gif'
    }
  })
  end
end

def make_event(scheduler, user_id, message_text)
  new_event = User.find(user_id).events.last
  event_date = parse_date(Nickel.parse(message_text).occurrences[0])
  event_time = parse_time(Nickel.parse(message_text).occurrences[0])
  new_event.update(event_date: event_date + " " + event_time, date: event_date, time: event_time)
  reminder_id = scheduler.at(new_event.event_date) do
    bot_send(new_event.user.id, "REMINDER: #{new_event.message} at #{Time.parse(event_time).strftime("%l:%M %P").strip}")
    new_event.destroy
  end
  puts reminder_id
  bot_send(new_event.user.id, "Setting your reminder: #{new_event.message} at #{Time.parse(new_event.time).strftime("%l:%M %P").strip} on #{Date.parse(new_event.date.to_s).strftime("%B %e, %Y")}")
  new_event.update(scheduler_id: reminder_id)
end

def parse_date(occurrence)
  occurrence.start_date.to_date.to_s.gsub("-", "/")
end

def parse_time(occurrence)
  occurrence.start_time.time.scan(/.{2}/).join(":")
end

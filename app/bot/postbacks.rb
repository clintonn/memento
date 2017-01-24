def tutorial(user_id)
  bot_send(user_id, "You can send me any message like this: \"Remind me to do X in 5 hours\"")
  bot_send(user_id, "You can even use exact dates: \"Remind me to volunteer at the food shelter next Saturday.")
  bot_send(user_id, "Or: \"Remind me to rent a timeshare on May 5.\" Feel free to experiment!")
  bot_send(user_id, "You can run this tutorial again using the navigation menu on the bottom left corner alongside other options!")
end


def show_reminders(user_id)
  @user = User.find(user_id)
  if @user.events.empty?
    bot_send(@user.id, "You have no events!")
  else
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
              buttons: [{ type: "postback", title: "Delete", payload: "delete #{reminder.scheduler_id}"}]
            }
          }
        }}, access_token: ENV['ACCESS_TOKEN'])
      sleep(0.76258739)
    end
    Bot.deliver({recipient: { id: @user.id },
    message: {
      attachment: {
        type: 'template',
        payload: {
          template_type: "button",
          text: "Or...delete them all?",
          buttons: [{ type: "postback", title: "DELETE ALL REMINDERS", payload: "destroy all"}]
          }
        }
      }
    }, access_token: ENV['ACCESS_TOKEN'])
  end
end

def delete_event(scheduler, scheduler_id)
  event = Event.where(scheduler_id: scheduler_id)[0]
  scheduler.unschedule(scheduler_id)
  bot_send(event.user.id, "Unscheduling that reminder!")
  event.destroy
end

def destroy_all(scheduler, sender_id)
  events = User.find(sender_id).events
  events.each {|event| scheduler.unschedule(event.scheduler_id) if event.scheduler_id}
  events.destroy_all
  bot_send(sender_id, "Deleted all reminders! 🔥 🚮 🔥")
end

def cyberbully(sender_id)
  user = User.find(sender_id)
  bot_type(user.id)
  sleep(0.5)
  bot_send(user.id, "henlo #{user.name.split(" ")[0]}")
  bot_type(user.id)
  sleep(0.5)
  bot_send(user.id, "helllo u STINKY #{user.name.split(" ")[0].upcase}")
  bot_type(user.id)
  sleep(0.5)
  bot_send(user.id, "go forget an important date ugly")
end

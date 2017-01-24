require "facebook/messenger"
include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

# initialize greeting for new users

Facebook::Messenger::Thread.set({
  setting_type: 'greeting',
  greeting: {
    text: 'Hello! Try setting a reminder by sending a message: "Remind me to pick up laundry in an hour." Click "get started" to get more info.'
  },
}, access_token: ENV['ACCESS_TOKEN'])

Facebook::Messenger::Thread.set({
  setting_type: 'call_to_actions',
  thread_state: 'new_thread',
  call_to_actions: [{
    payload: 'tutorial'
  }]
}, access_token: ENV['ACCESS_TOKEN'])

# sets persistent menu that allows for postback methods (payload: METHOD) to be called

Facebook::Messenger::Thread.set({
  setting_type: 'call_to_actions',
  thread_state: 'existing_thread',
  call_to_actions: [
    {
      type: 'postback',
      title: 'Tutorial',
      payload: 'tutorial'
    },
    {
      type: 'postback',
      title: 'See all reminders',
      payload: 'show_reminders'
    },
    {
      type: 'postback',
      title: 'cyberbully me',
      payload: 'cyberbully'
    }
  ]
}, access_token: ENV['ACCESS_TOKEN'])

def bot_send(user_id, msg)
  bot_type(user_id)
  sleep(1.5)
  Bot.deliver({
    recipient: {
      id: user_id
    },
    message: {
      text: "#{msg}"
    }
  }, access_token: ENV['ACCESS_TOKEN'])
end

def bot_type(user_id)
  Bot.deliver({
    recipient: {
      id: user_id
    },
    sender_action: 'typing_on'
  }, access_token: ENV['ACCESS_TOKEN'])
end

def format_message(str)
  first_words = str.downcase.split[0..2].delete_if do |word|
    ["remind", "me", "to"].include?(word)
  end.join(" ")
  out = first_words + str.split[3..-1].join(" ")
  out[0] = out[0].capitalize
  out
end

require "facebook/messenger"
include Facebook::Messenger

Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

# initialize greeting for new users

Facebook::Messenger::Thread.set({
  setting_type: 'greeting',
  greeting: {
    text: 'Hello! Send a reminder to Memento to be reminded about anything. Try "Remind me to pick up laundry in an hour."'
  },
}, access_token: ENV['ACCESS_TOKEN'])

# sets persistent menu that allows for postback methods (payload: METHOD) to be called

Facebook::Messenger::Thread.set({
  setting_type: 'call_to_actions',
  thread_state: 'existing_thread',
  call_to_actions: [
    {
      type: 'postback',
      title: 'Help',
      payload: 'show_help'
    },
    {
      type: 'postback',
      title: 'See all reminders',
      payload: 'show_reminders'
    }
  ]
}, access_token: ENV['ACCESS_TOKEN'])

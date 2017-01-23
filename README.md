
# Memento

![memento-icon](http://i.imgur.com/Unydb1G.png?2)

Memento is a Facebook Messenger bot that's your personal nagger. Powered by the facebook-messenger gem.

Run it on a Rails server. Deploy to Heroku. Name it whatever you want, actually. It'll nag you all the same.

### Installation

Make sure you have Rails and Ruby installed on your local environment.

Navigate to the repo directory and run: `$ figaro install` to set environment variables.

[Register an app](https://developers.facebook.com/) on Facebook. [Make a page](https://www.facebook.com/pages/create/) linked to it.

On the dashboard of your Facebook app, add a Messenger product:

![facebook-app-dashboard](http://i.imgur.com/vsJ0RHX.png)

Set some environment variables in the `application.yml` file Figaro touched in the `config/` directory. You should enter an `ACCESS_TOKEN`, which you can get via your Facebook Messenger app dashboard and a `VERIFY_TOKEN`, which you'll generate later when creating a webhook.

Then set up a https:// server that can route POST requests to a specified callback URI.

If you're developing locally, [ngrok](https://ngrok.com/) is an easy way to set up an https:// forwarding URL that tunnels to your local http server.

Run the rails server by running `$ bundle install` and `rails s`, and in a separate terminal window, run ngrok via `$ PATH/TO/ngrok 3000`. 3000 is whatever your Rails listening port is.

Back at the Facebook developer dashboard, go to your Messenger settings for your app. Set up a webhook, and select messages and messaging_postbacks. Enter the ngrok URI, set yourself a verify token, and enter that in your `application.yml` file.

Upon receiving the POST request, the Facebook Messenger gem will fire back a subscribe response with your verify token. If all's good, you can define a success message in your `app/bot/bot.rb` file:

```Ruby
Bot.on :message do |message|
  message.reply('Success! Got your message.')
end
```

Which will reply to your messages with "Success!" every time you send a message.

class User < ApplicationRecord
  has_many :events

  def update_attributes
    uri = "https://graph.facebook.com/v2.6/#{self.id}?access_token=#{ENV['ACCESS_TOKEN']}"
    puts uri
    res = JSON.parse(RestClient.get(uri))
    self.update(
      name: "#{res['first_name']} #{res['last_name']}",
      timezone: res['timezone']
    )
  end
end

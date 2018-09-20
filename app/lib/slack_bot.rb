class SlackBot
  @@token = ENV['SLACK_API_TOKEN'] # maybe it makes no sense to have this separate from the stuff in application_helper?
  
  #this feels kinda dumb, idk
  @@sendable_ingredient_emoji = Ingredient.all.map { |ingredient| ingredient.emoji }
  @@sendable_cookie_emoji = CookieRecipe.all.map { |cookie| cookie.emoji }

  def self.startup
		self.add_all_users
  end

  def self.give_ingredients_to_all_users(ingredient, count)
    Owner.all.each do |member|
      count.times do 
        member.receive_giveable_ingredient(ingredient)
      end
    end
  end

  def self.add_all_users
    users = self.get_user_list
    if users
      users.each do |user_id|
        self.add_user_if_new(user_id) unless self.user_is_a_bot(user_id)
      end
    end
  end

  def self.get_user_list
    channel_id = "CC7VBU8UW"
    # request_url = "https://slack.com/api/users.list?token=#{@@token}&pretty=1"
    request_url = "https://slack.com/api/channels.info?token=#{@@token}&channel=#{channel_id}&pretty=1"
    response = JSON.parse(RestClient.get(request_url))
    response["ok"] ? response["channel"]["members"] : false
  end

  def self.user_is_a_bot(user_id)
    false # bots are real people too
    # member == "USLACKBOT" || member["profile"]["bot_id"]
  end

  def self.add_user_if_new(user_id)
    Owner.find_or_create_by(slack_id: user_id)
  end

  def self.get_name_of_user(user)
    request_url = "https://slack.com/api/users.info?token=#{@@token}&user=#{user.slack_id}&pretty=1"
    response = JSON.parse(RestClient.get(request_url))
    response["user"]["real_name"]
  end

  def self.sendable_ingredient_emoji
    @@sendable_ingredient_emoji
  end

  def self.sendable_cookie_emoji
    @@sendable_cookie_emoji
  end

  def self.token
    @@token
  end

  def self.send_sent_item_messages(sender, recipient, object, count)
    self.send_message(sender.slack_id, "You gave #{":#{object}:" * count} to #{SlackBot.get_name_of_user(recipient)}!")
    self.send_message(recipient.slack_id, "#{SlackBot.get_name_of_user(sender)} gave you #{":#{object}:" * count}!")
  end

  def self.send_ingredient(sender, recipient, item, count)
    successfully_sent = sender.give_ingredient_to(recipient, Ingredient.find_by(emoji: item), count)
    self.send_sent_item_messages(sender, recipient, item, count) if successfully_sent
  end

  def self.send_cookie(sender, recipient, item, count)
    successfully_sent = sender.give_cookie_to(recipient, CookieRecipe.find_by(emoji: item), count)
    self.send_sent_item_messages(sender, recipient, item, count) if successfully_sent
  end

  def self.send_message(channel_id, text)
    request_url = "https://slack.com/api/chat.postMessage?token=#{SlackBot.token}&channel=#{channel_id}&text=#{text}&pretty=1"
    response = RestClient.get(request_url)
  end
end
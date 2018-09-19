class EventsController < ApplicationController
	skip_before_action :verify_authenticity_token
	http_basic_authenticate_with name: "kim", password: "ethan", only: :distribute_ingredients

	def processing
		puts "received event!"
		# Extract the Event payload from the request and parse the JSON
		request_data = JSON.parse(request.body.read)
		puts "JSON DATA"

		# Check the verification token provided with the request to make sure it matches the verification token in
		# your app's setting to confirm that the request came from Slack.
		unless SLACK_CONFIG[:slack_verification_token] == request_data['token']
			halt 403, "Invalid Slack verification token received: #{request_data['token']}"
		end

		case request_data['type']
			# When you enter your Events webhook URL into your app's Event Subscription settings, Slack verifies the
			# URL's authenticity by sending a challenge token to your endpoint, expecting your app to echo it back.
			# More info: https://api.slack.com/events/url_verification
			when 'url_verification'
				render plain: request_data['challenge']

			when 'event_callback'
				# Get the Team ID and Event data from the request object
				team_id = request_data['team_id']
				event_data = request_data['event']
				
				case event_data['type']
				when 'message'
					message_sent(event_data)
				when 'team_join'
					user_joined(team_id, event_data)
				end
				# Return HTTP status code 200 so Slack knows we've received the Event
				head 200
		end
	end

	# route methods
	def list_inventory
		request_data = parse_url_encoded_data(request.body.read)
		render json: cookie_inventory(request_data["user_id"])
	end

	def list_bakeable_cookies
		request_data = parse_url_encoded_data(request.body.read)
		render json: get_bakeable_cookies(request_data["user_id"])
	end

	def bake_cookie_event
		request_data = parse_url_encoded_data(request.body.read)
		render json: bake_cookie(request_data["user_id"], request_data["text"])
	end

	def distribute_ingredients
		count = params["quantity"].to_i
		ingredient = Ingredient.find(params["ingredient"])
		if count > 0
			SlackBot.give_ingredients_to_all_users(ingredient, count)
			puts "Sent all users #{count} #{ingredient.name}"
			# Events.send_message(channel_id, "Everyone has received #{count} more :#{ingredient.emoji}: to send to others!")
			# "(ADMIN) Sent all users #{count} #{ingredient.name}"
		else
			puts "Couldn't send ingredients, invalid quantity"
		end
	end
	

	#helper function for below
	def get_targeted_user(message)
    username_location = message.index("<@")
    if username_location
      user_id = message[username_location + 2..username_location + 10]
      Owner.find_by(slack_id: user_id)
    end
  end

	private
  def parse_url_encoded_data(string)
    properties = string.split("&")
    # some slightly arcane code stolen from stackoverflow
    # turns an array of strings of the form "key=value" into a hash
    Hash[properties.map do |property|
      property.split("=") 
    end]
	end
	
	#i feel like this logic should actually probably be in the model(s)
	def cookie_inventory(user_id)
		owner = Owner.find_by(slack_id: user_id)
    ingredients = owner.list_all_ingredients
    giveable_cookies = owner.list_all_giveable_cookies
    received_cookies = owner.list_all_received_cookies

    response =
    {
      :text => "Your Ingredients:\n\n",
      :attachments => []
    }

    ingredients.each do |ingredient_info|
      ingredient = Ingredient.find(ingredient_info[:id])
      response[:text] << "You have #{ingredient_info[:giveable]} giveable #{ingredient.name} :#{ingredient.emoji}:, and #{ingredient_info[:received]} received from others!\n"
    end

    response[:text] << "\nCookies you've baked (can be sent to others):\n"
    giveable_cookies.each do |cookie_id, count|
      cookie = OwnedCookie.find(cookie_id)
      response[:text] << (":#{cookie.cookie_recipe.emoji}:" * count) + "\n"
    end
    response[:text] << "\nCookies others have sent to you:\n"
    received_cookies.each do |cookie_id, count|
      cookie = OwnedCookie.find(cookie_id)
      response[:text] << (":#{cookie.cookie_recipe.emoji}:" * count) + "\n"
    end

    response.to_json
	end

	def get_bakeable_cookies(user_id)
    response =
    {
      :text => "",
      :attachments => []
    }

    user = Owner.find_by(slack_id: user_id)
    recipes = user.list_cookie_recipes_you_can_bake
    if recipes.length > 0
      response[:text] << "Cookies you can make:"
      recipes.each do |recipe|
        response[:attachments] << {"text" => ":#{recipe.emoji}:"}
      end
    else
      closest_cookie = user.list_closest_cookable_cookie
      response[:text] << "You don't have enough ingredients to make a cookie yet. The cookie you're closest to is a :#{closest_cookie.emoji}:, which needs:\n"

      user.remaining_needed_ingredients_for(closest_cookie).each do |ingredient_id, count|
        response[:attachments] << {"text" => ":#{Ingredient.find(ingredient_id).emoji}:" * count}
      end
    end

    response.to_json
  end

  def bake_cookie(user_id, cookie_emoji)
    if cookie_emoji
      cookie_emoji = cookie_emoji.gsub("%3A", "")
      recipe = CookieRecipe.find_by(emoji: cookie_emoji)
      if recipe
        user = Owner.find_by(slack_id: user_id)
        if user.bake_cookies(recipe)
          "Baked a #{recipe.name} Cookie! :#{recipe.emoji}: :tada:"
        else
          response = "You don't have enough ingredients to make a #{recipe.name} Cookie. You still need:\n"
          needed_ingredients = user.remaining_needed_ingredients_for(recipe)
          needed_ingredients.each do |ingredient_id, count|
            response << ":#{Ingredient.find(ingredient_id).emoji}:" * count + "\n"
          end
          response
        end
      else
        "\":#{cookie_emoji}:\" is not a recognized cookie emoji. Use `/cookies-bakeable-list` to see available types."
      end
    else
      "Enter a cookie type after `/cookies-bake` to make cookies. Use `/cookies-bakeable-list` to see available types."
    end
	end
	
	# event handling stuff
	def user_joined(team_id, event_data)
		user_id = event_data['user']['id']
		SlackBot.add_user_if_new(user_id)
  end

  def message_sent(event_data)
    user_id = event_data["user"]
    text = event_data["text"]
    channel_id = event_data["channel"]
    puts "message text: #{text}"
		if text
			targeted_user = self.get_targeted_user(text)
      if targeted_user
        sending_user = Owner.find_by(slack_id: user_id)
        if targeted_user != sending_user
          SlackBot.sendable_ingredient_emoji.each do |sendable_ingredient|
            if text.include?(":#{sendable_ingredient}:")
							SlackBot.send_ingredient(sending_user, targeted_user, sendable_ingredient)
						end
					end
					SlackBot.sendable_cookie_emoji.each do |sendable_cookie|
						if text.include?(":#{sendable_cookie}:")
							binding.pry
							SlackBot.send_cookie(sending_user, targeted_user, sendable_cookie)
						end
					end
				else
					SlackBot.send_message(sending_user.slack_id, "You can't send ingredients to yourself!")
				end
      end
    end
	end
end

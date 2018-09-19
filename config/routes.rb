Rails.application.routes.draw do
	# resource :owner, only: [:index]
	root 'owners#index'
	get "/example/", to: "owners#exampleaction"
	# get "/events", to: "events#processing"

	# from events (messages etc) in slack
	post "/events", to: "events#processing"

	# from slash commands in slack
	post "/list_inventory", to: "events#list_inventory"
	post "/list_bakeable_cookies", to: "events#list_bakeable_cookies"
	post "/bake_cookie", to: "events#bake_cookie"

	# from website
	post "/distribute_ingredients", to: "events#distribute_ingredients"
end
